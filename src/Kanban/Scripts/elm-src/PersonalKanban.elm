module PersonalKanban where

import Effects exposing (Effects, none)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import TaskColumn
import TaskHeader
import TaskBox
import AddTaskPopup
import Task
import Json.Decode exposing (..)

-- ACTION

type Action
    = NoOp
    | TaskColumnAction Int TaskColumn.Action
    | AddNewTaskToBoardRequest
    | AddNewTaskToBoard String
    | RemoveTaskFromBoardRequest Int Int
    | PopupAction AddTaskPopup.Action    
    | MoveTask MoveDirection Int (Int, String)
    | TasksLoaded (Maybe (List (Int, String)))

type MoveDirection
  = Left
  | Right

-- MODEL

type alias Model =
    { columns : List (Int, TaskHeader.Model, TaskColumn.Model)
    , popup : AddTaskPopup.Model }

initColumns : List (Int, TaskHeader.Model, TaskColumn.Model)
initColumns =
  let
    todoColumn =
      ( 1
      , { name = "To do", addActionAvailable = True }
      , { tasks = [], nextTaskID = 2, position = TaskColumn.First })
    fakeTaskInProgress = TaskBox.withDescription "Fake task" TaskBox.BothWays
    inProgressColumn =
      ( 2
      , { name = "In progress", addActionAvailable = False }
      , { tasks = [], nextTaskID = 2, position = TaskColumn.Surrounded })
    fakeTaskDone = TaskBox.withDescription "Fake task" TaskBox.OnlyLeft
    doneColumn =
      ( 3
      , { name = "Done", addActionAvailable = False }
      , { tasks = [], nextTaskID = 2, position = TaskColumn.Last })
  in
    [todoColumn, inProgressColumn, doneColumn]


init : (Model, Effects Action)
init =
  let
    model =
      { columns = initColumns
      , popup = AddTaskPopup.init }
  in
    ( model, getTodoTasks )

-- UPDATE

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)

    TaskColumnAction columnId columnAction ->
      let
        updateColumn (id, h, c) =
          if id == columnId
            then (id, h, TaskColumn.update columnAction c)
            else (id, h, c)
        newColumns = List.map updateColumn model.columns
        model' =
          { model
          | columns = newColumns }
      in
        (model', Effects.none)
        
    RemoveTaskFromBoardRequest columnId taskId ->
      let
        model' = model
      in
        (model', Effects.none)

    AddNewTaskToBoardRequest ->
      let
        model' =
          { model
          | popup = AddTaskPopup.update AddTaskPopup.Show model.popup }
      in
        (model', Effects.none)

    AddNewTaskToBoard desc ->
      let
        updateFirstColumn index (id, headerModel, columnModel) =
          if index == 0 then
            (id, headerModel, TaskColumn.update (TaskColumn.AddTask desc) columnModel)
          else
            (id, headerModel, columnModel)
        newColumns : List (Int, TaskHeader.Model, TaskColumn.Model)
        newColumns = List.indexedMap updateFirstColumn model.columns
        model' : Model
        model' =
          { model
          | columns = newColumns
          , popup = AddTaskPopup.update AddTaskPopup.Hide model.popup }
      in
        (model', postNewTask desc)

    PopupAction popupAction ->
      let
        model' =
          { model
          | popup = AddTaskPopup.update popupAction model.popup }
      in
        (model', Effects.none)

    MoveTask direction columnId (taskId, desc) ->
      let
        targetColumnId =
          case direction of
            Left -> columnId - 1
            Right -> columnId + 1
        newColumns = moveTask model.columns columnId targetColumnId taskId desc
        model' =
          { model
          | columns = newColumns }
      in
        (model', Effects.none)
        
    TasksLoaded maybeNames -> 
        case maybeNames of
            Just names -> 
                let
                    updateFirstColumn index (id, headerModel, columnModel) =
                        if index == 0 then
                            let updateColumnWithNewTasks = 
                                names 
                                |> List.foldl (\(id, name) acc -> TaskColumn.update (TaskColumn.AddTask name) acc) columnModel
                            in (id, headerModel, updateColumnWithNewTasks)
                        else
                            (id, headerModel, columnModel)
                    newColumns : List (Int, TaskHeader.Model, TaskColumn.Model)
                    newColumns = List.indexedMap updateFirstColumn model.columns
                    model' : Model
                    model' =
                    { model
                    | columns = newColumns
                    , popup = AddTaskPopup.update AddTaskPopup.Hide model.popup }
                in
                    (model', Effects.none)
            Nothing ->
                (model, Effects.none)

moveTask : List (Int, TaskHeader.Model, TaskColumn.Model) -> Int -> Int -> Int -> String -> List (Int, TaskHeader.Model, TaskColumn.Model)
moveTask columns columnId targetColumnId taskId taskDescription =
  let
    addTaskToRightColumn (id, headerModel, columnModel) =
      if id == targetColumnId then
        (id, headerModel, TaskColumn.update (TaskColumn.AddTask taskDescription) columnModel)
      else
        (id, headerModel, columnModel)
    removeFromColumn (id, headerModel, columnModel) =
      if id == columnId then
        (id, headerModel, TaskColumn.update (TaskColumn.RemoveTask taskId) columnModel)
      else
        (id, headerModel, columnModel)
  in
    columns |> List.map (addTaskToRightColumn >> removeFromColumn)
-- VIEW

tableStyle : Attribute
tableStyle =
  style
    [ ("table-layout", "fixed")
    , ("width", "100%")
    , ("height", "100%")
    , ("border-collapse", "collapse") ]

cellStyle : Attribute
cellStyle =
  style
    [ ("border", "1px solid black")
    , ("vertical-align", "top")]

headerStyle : Attribute
headerStyle =
  style
    [ ("height", "100px") ]

headerCellStyle : Attribute
headerCellStyle =
  style
    [("border", "1px solid black")]

view : Signal.Address Action -> Model -> Html
view address model =
  let
    headerContext = { addTaskAddress = Signal.forwardTo address (always AddNewTaskToBoardRequest)}
    viewHeader headerModel =
      th [headerCellStyle] [TaskHeader.view headerContext headerModel]


    viewColumnCell (id, _, column) =
        let
          taskColumnContext : TaskColumn.Context
          taskColumnContext =
            { moveRightAddress = Signal.forwardTo address <| MoveTask Right id
            , moveLeftAddress = Signal.forwardTo address <| MoveTask Left id 
            , removeTaskAddress = Signal.forwardTo address <| RemoveTaskFromBoardRequest id }
        in
          td [cellStyle]
            [ TaskColumn.view taskColumnContext (Signal.forwardTo address (TaskColumnAction id)) column ]
    headersRow = tr [headerStyle] <| List.map viewHeader (List.map (\ (_, h, _) -> h) model.columns)
    cellsRow = tr [] <| List.map viewColumnCell model.columns
    popupContext = { addTaskAddress = Signal.forwardTo address AddNewTaskToBoard }
    popup = AddTaskPopup.view  popupContext (Signal.forwardTo address PopupAction) model.popup
  in
    span []
      [ table [tableStyle] [headersRow, cellsRow]
      , popup ]

-- EFFECTS

getTodoTasks : Effects Action
getTodoTasks =
  Http.get taskModelsDecoder "/api/task"
    |> Task.toMaybe
    |> Task.map TasksLoaded
    |> Effects.task
    
taskModelsDecoder : Json.Decode.Decoder (List (Int,String))
taskModelsDecoder =
    Json.Decode.list taskModelDecoder
    
taskModelDecoder : Json.Decode.Decoder (Int,String)
taskModelDecoder =
    Json.Decode.object2 (,)
      ("Id" := Json.Decode.int)
      ("Description" := Json.Decode.string)
    
postNewTask : String -> Effects Action
postNewTask description =
    let 
        url = "/api/task"
        body = Http.string <| "\"" ++ description ++ "\""
        decoder = Json.Decode.succeed ()
        httpTask = 
            Http.send Http.defaultSettings
                { verb = "POST"
                , headers = [("Content-Type", "application/json")]
                , url = url
                , body = body
                }
    in
        httpTask
        |> Task.toMaybe
        |> Task.map (always NoOp)
        |> Effects.task 
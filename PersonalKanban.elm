module PersonalKanban where

import Effects exposing (Effects, none)
import Html exposing (..)
import Html.Attributes exposing (..)
import TaskColumn
import TaskHeader
import TaskBox
import AddTaskPopup


-- ACTION

type Action
    = NoOp
    | TaskColumnAction Int TaskColumn.Action
    | AddNewTaskToBoardRequest
    | PopupAction AddTaskPopup.Action
    | AddNewTaskToBoard String
    | MoveTask MoveDirection Int Int

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
    fakeTaskTodo = TaskBox.withDescription "Fake task" TaskBox.OnlyRight
    todoColumn =
      ( 1
      , { name = "To do", addActionAvailable = True }
      , { tasks = [(1, fakeTaskTodo)], nextTaskID = 2, position = TaskColumn.First })
    fakeTaskInProgress = TaskBox.withDescription "Fake task" TaskBox.BothWays
    inProgressColumn =
      ( 2
      , { name = "In progress", addActionAvailable = False }
      , { tasks = [(1, fakeTaskInProgress)], nextTaskID = 2, position = TaskColumn.Surrounded })
    fakeTaskDone = TaskBox.withDescription "Fake task" TaskBox.OnlyLeft
    doneColumn =
      ( 3
      , { name = "Done", addActionAvailable = False }
      , { tasks = [(1, fakeTaskDone)], nextTaskID = 2, position = TaskColumn.Last })
  in
    [todoColumn, inProgressColumn, doneColumn]


init : (Model, Effects Action)
init =
  let
    model =
      { columns = initColumns
      , popup = AddTaskPopup.init }
  in
    ( model, Effects.none )


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
        newModel =
          { model
          | columns = newColumns }
      in
        (newModel, Effects.none)

    AddNewTaskToBoardRequest ->
      let
        newModel =
          { model
          | popup = AddTaskPopup.update AddTaskPopup.Show model.popup }
      in
        (newModel, Effects.none)

    AddNewTaskToBoard desc ->
      let
        updateFirstColumn index (id, headerModel, columnModel) =
          if index == 0 then
            (id, headerModel, TaskColumn.update (TaskColumn.AddTask desc) columnModel)
          else
            (id, headerModel, columnModel)
        newColumns : List (Int, TaskHeader.Model, TaskColumn.Model)
        newColumns = List.indexedMap updateFirstColumn model.columns
        newModel : Model
        newModel =
          { model
          | columns = newColumns
          , popup = AddTaskPopup.update AddTaskPopup.Hide model.popup }
      in
        (newModel, Effects.none)

    PopupAction popupAction ->
      let
        newModel =
          { model
          | popup = AddTaskPopup.update popupAction model.popup }
      in
        (newModel, Effects.none)

    MoveTask direction columnId taskId ->
      let
        targetColumnId =
          case direction of
            Left -> columnId - 1
            Right -> columnId + 1
        newColumns = moveTask model.columns columnId targetColumnId taskId "MOVED TASK"
        newModel =
          { model
          | columns = newColumns }
      in
        (newModel, Effects.none)

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
            , moveLeftAddress = Signal.forwardTo address <| MoveTask Left id }
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

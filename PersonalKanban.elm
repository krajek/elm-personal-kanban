module PersonalKanban where

import Effects exposing (Effects, none)
import Html exposing (..)
import Html.Attributes exposing (..)
import TaskColumn
import TaskHeader
import AddTaskPopup


-- ACTION

type Action
    = NoOp
    | TaskColumnAction TaskColumn.Action
    | AddNewTaskToBoardRequest
    | PopupAction AddTaskPopup.Action
    | AddNewTaskToBoard String

-- MODEL

type alias Model =
    { columns : List (TaskHeader.Model, TaskColumn.Model)
    , popup : AddTaskPopup.Model }


initColumns : List (TaskHeader.Model, TaskColumn.Model)
initColumns =
  let
    fakeTask = { description = "Fake task "}
    todoColumn = ( {name = "To do" }, { tasks = [fakeTask] })
    inProgressColumn = ( {name = "In progress" }, { tasks = [fakeTask] })
    doneColumn = ( {name = "Done"}, { tasks = [fakeTask] })
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

    TaskColumnAction columnAction ->
      (model, Effects.none)

    AddNewTaskToBoardRequest ->
      let
        newModel =
          { model
          | popup = AddTaskPopup.update AddTaskPopup.Show model.popup }
      in
        (newModel, Effects.none)

    AddNewTaskToBoard desc ->
      let
        updateFirstColumn index (headerModel, columnModel) =
          if index == 0 then
            (headerModel, TaskColumn.update (TaskColumn.AddTask desc) columnModel)
          else
            (headerModel, columnModel)
        newColumns : List (TaskHeader.Model, TaskColumn.Model)
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
    viewColumnCell column =
        td [cellStyle]
          [ TaskColumn.view (Signal.forwardTo address (TaskColumnAction)) column ]
    headersRow = tr [headerStyle] <| List.map viewHeader (List.map fst model.columns)
    cellsRow = tr [] <| List.map viewColumnCell (List.map snd model.columns)
    popupContext = { addTaskAddress = Signal.forwardTo address AddNewTaskToBoard }
    popup = AddTaskPopup.view  popupContext (Signal.forwardTo address PopupAction) model.popup
  in
    span []
      [ table [tableStyle] [headersRow, cellsRow]
      , popup ]

module KanbanBoard.View where

import Html exposing (..)
import Html.Attributes exposing (..)
import TaskColumn
import TaskHeader
import TaskBox
import AddTaskPopup

import KanbanBoard.Action exposing (Action(..), MoveDirection(..))
import KanbanBoard.Model exposing(Model)

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
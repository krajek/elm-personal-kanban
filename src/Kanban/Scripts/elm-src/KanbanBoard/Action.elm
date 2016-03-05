module KanbanBoard.Action where

import TaskColumn
import TaskHeader
import TaskBox
import AddTaskPopup
import Effects exposing (Effects)

import KanbanBoard.Model exposing (Model, initColumns)
-- ACTION

type Action
    = NoOp
    | TaskColumnAction Int TaskColumn.Action
    | AddNewTaskToBoardRequest
    | AddNewTaskToBoard String
    | AddNewTaskToBoardConfirmed (Maybe (String, Int))
    | RemoveTaskFromBoardRequest Int Int
    | PopupAction AddTaskPopup.Action    
    | MoveTask MoveDirection Int (Int, String)
    | TasksLoaded (Maybe (List (Int, String)))

type MoveDirection
  = Left
  | Right
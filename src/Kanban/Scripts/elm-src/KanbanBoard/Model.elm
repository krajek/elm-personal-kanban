module KanbanBoard.Model where

import TaskColumn
import TaskHeader
import TaskBox
import Task
import AddTaskPopup
import Effects exposing (Effects)


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
      , { tasks = [], position = TaskColumn.First })
    fakeTaskInProgress = TaskBox.withDescription "Fake task" TaskBox.BothWays
    inProgressColumn =
      ( 2
      , { name = "In progress", addActionAvailable = False }
      , { tasks = [], position = TaskColumn.Surrounded })
    fakeTaskDone = TaskBox.withDescription "Fake task" TaskBox.OnlyLeft
    doneColumn =
      ( 3
      , { name = "Done", addActionAvailable = False }
      , { tasks = [], position = TaskColumn.Last })
  in
    [todoColumn, inProgressColumn, doneColumn]
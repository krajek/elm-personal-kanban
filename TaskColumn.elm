module TaskColumn where

import Html exposing (..)
import Html.Attributes exposing (style)
import TaskBox

type Action
  = AddTask String
  | TaskBoxAction Int TaskBox.Action

type alias Model =
  { tasks : List (Int, TaskBox.Model)
  , nextTaskID : Int }

update : Action -> Model -> Model
update action model =
  case action of
    AddTask content ->
      let
        newTask = (model.nextTaskID, TaskBox.withDescription content)
        newModel =
            { model
            | tasks = model.tasks ++ [newTask]
            , nextTaskID = model.nextTaskID + 1 }
      in
        newModel

    TaskBoxAction taskId taskBoxAction ->
      let
        updateTask (id, task) =
          if taskId == id
            then (id, TaskBox.update taskBoxAction task)
            else (id, task)
        newModel =
          { model
          | tasks = List.map updateTask model.tasks }
      in
        newModel


view : Signal.Address Action -> Model -> Html
view address model =
  let
    viewTask (taskId, task) =
      let
        taskBoxAddress = Signal.forwardTo address <| TaskBoxAction taskId
      in
        TaskBox.view taskBoxAddress task
    tasks = List.map viewTask model.tasks
  in
    section [] tasks

module TaskColumn where

import Html exposing (..)
import Html.Attributes exposing (style)
import TaskBox

type Action
  = AddTask String
  | TaskBoxAction TaskBox.Action

type alias Model =
  { tasks : List (Int, TaskBox.Model)
  , nextTaskID : Int }

update : Action -> Model -> Model
update action model =
  case action of
    AddTask content ->
      let
        newTask = (model.nextTaskID, TaskBox.withDescription content)
      in
        { model
        | tasks = model.tasks ++ [newTask]
        , nextTaskID = model.nextTaskID + 1 }

    TaskBoxAction taskBoxAction ->
      model


view : Signal.Address Action -> Model -> Html
view address model =
  let
    taskBoxAddress = Signal.forwardTo address TaskBoxAction
    tasks = List.map (snd >> (TaskBox.view taskBoxAddress)) model.tasks
  in
    section [] tasks

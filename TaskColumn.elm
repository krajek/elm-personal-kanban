module TaskColumn where

import Html exposing (..)
import Html.Attributes exposing (style)
import TaskBox

type Action
  = AddTask String
  | TaskBoxAction TaskBox.Action

type alias Model =
  { tasks : List TaskBox.Model }

update : Action -> Model -> Model
update action model =
  case action of
    AddTask content ->
      let
        netTask = TaskBox.withDescription content
      in
        { model
        | tasks = model.tasks ++ [netTask]}

    TaskBoxAction taskBoxAction ->
      model
view : Signal.Address Action -> Model -> Html
view address model =
  let
    taskBoxAddress = Signal.forwardTo address TaskBoxAction
    tasks = List.map (TaskBox.view taskBoxAddress)  model.tasks
  in
    section [] tasks

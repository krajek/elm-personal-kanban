module TaskColumn where

import Html exposing (..)
import Html.Attributes exposing (style)
import TaskBox

type Action =
  AddTask String

type alias Model =
  { tasks : List TaskBox.Model }

update : Action -> Model -> Model
update action model =
  case action of
    AddTask content ->
      let
        netTask = { description = content }
      in
        { model
        | tasks = model.tasks ++ [netTask]}

view : Signal.Address Action -> Model -> Html
view address model =
  let
    tasks = List.map TaskBox.view model.tasks
  in
    section [] tasks

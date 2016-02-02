module TaskColumn where

import Html exposing (..)

type Action =
  AddTask String

type alias Model =
  { tasks : List String }

update : Action -> Model -> Model
update action model =
  case action of
    AddTask content ->
      { model
      | tasks = model.tasks ++ [content]}

view : Signal.Address Action -> Model -> Html
view address model =
  let
    tasks = List.map (\content -> h4 [] [text content]) model.tasks
  in
    section [] tasks

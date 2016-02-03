module TaskColumn where

import Html exposing (..)
import Html.Attributes exposing (style)

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

taskStyle =
  style
  [ ("border", "1px solid black")
  , ("margin", "20px 10px")]

view : Signal.Address Action -> Model -> Html
view address model =
  let
    viewTask content =
      p [taskStyle] [text content]
    tasks = List.map viewTask model.tasks
  in
    section [] tasks

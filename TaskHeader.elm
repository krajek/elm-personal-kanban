module TaskHeader(Model, view) where

import Html exposing (..)
import Html.Events exposing (..)


type alias Model =
  { name : String }


type alias Context =
  { addTaskAddress : Signal.Address () }

view : Context -> Model -> Html
view context model =
  div []
    [ h2 [] [text model.name]
    , button [onClick context.addTaskAddress ()] [text "+"]]

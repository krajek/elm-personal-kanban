module TaskHeader(Model, view) where

import Html exposing (..)


type alias Model =
  { name : String }


view : Model -> Html
view model =
  h2 [] [text model.name]

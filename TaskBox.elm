module TaskBox where

import Html exposing (p, Html, text)
import Html.Attributes exposing (style)

type alias Model =
  { description : String }

-- VIEW

taskStyle =
  style
  [ ("border", "1px solid black")
  , ("margin", "20px 10px")
  , ("cursor", "pointer")]

view : Model -> Html
view model =
  p [taskStyle] [text model.description]

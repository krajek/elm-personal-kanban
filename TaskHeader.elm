module TaskHeader(Model, view) where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (style)


type alias Model =
  { name : String }


type alias Context =
  { addTaskAddress : Signal.Address () }

headerTextStyle : Attribute
headerTextStyle =
  style
    [ ("font-size", "x-large") ]

buttonStyle =
  style
    [ ("float", "right")
    , ("margin-right", "10px")]

view : Context -> Model -> Html
view context model =
  span []
    [ span [headerTextStyle] [text model.name]
    , button [buttonStyle, onClick context.addTaskAddress ()] [text "+"]]

module TaskHeader(Model, view) where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (style)


type alias Model =
  { name : String
  , addActionAvailable : Bool }


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
  let
    buttonPart =
      if model.addActionAvailable
        then [button [buttonStyle, onClick context.addTaskAddress ()] [text "+"]]
        else []
    labelPart = [ span [headerTextStyle] [text model.name] ]
  in
    span []
      <| labelPart ++ buttonPart

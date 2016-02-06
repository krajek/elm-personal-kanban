module AddTaskPopup(Model, init, Action(Show), update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

-- MODEL

type alias Model =
  { visible :  Bool }


init : Model
init =
  { visible = False }

-- UPDATE

type Action
  = Show
  | Cancel

update : Action -> Model -> Model
update action model =
  case action of
    Show -> { model | visible = True }
    Cancel -> { model | visible = False}

-- VIEW

windowStyle :  Bool -> Attribute
windowStyle visible =
  style
    [ ("position", "absolute")
    , ("display", if visible then "block" else "none")
    , ("top",  "25%")
    , ("left",  "25%")
    , ("width",  "50%")
    , ("height",  "50%")
    , ("padding",  "16px")
    , ("border",  "16px solid orange")
    , ("background-color",  "white")
    , ("z-index", "1002")
    , ("overflow",  "auto")]

view :  Signal.Address Action -> Model -> Html
view address model =
  let
    popupContent = button [onClick address Cancel] [text "Cancel"]
  in
    div [windowStyle model.visible] [popupContent]

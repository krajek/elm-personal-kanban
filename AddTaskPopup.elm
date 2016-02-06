module AddTaskPopup(Model, init, Action(Show), update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, targetValue, on)

-- MODEL

type alias Model =
  { visible :  Bool
  , taskDescription : String }


init : Model
init =
  { visible = False
  , taskDescription = "" }

-- UPDATE

type Action
  = Show
  | Cancel
  | TaskDescription String

update : Action -> Model -> Model
update action model =
  case action of
    Show -> { model | visible = True }
    Cancel -> { model | visible = False}
    TaskDescription desc -> { model | taskDescription = desc }

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
    taskInput = input
        [ placeholder "Enter task description"
        , value model.taskDescription
        , on "input" targetValue (Signal.message address << TaskDescription)
        ]
        []
    cancelButton = button [onClick address Cancel] [text "Cancel"]
    popupContent = div [] [taskInput, cancelButton]
  in
    div [windowStyle model.visible] [popupContent]

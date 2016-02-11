module AddTaskPopup(Model, init, Action(Show, Hide), update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, targetValue, on)
import String

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
  | Hide
  | TaskDescription String

update : Action -> Model -> Model
update action model =
  case action of
    Show -> { init | visible = True }
    Hide -> { model | visible = False}
    TaskDescription desc -> { model | taskDescription = desc }

-- VIEW

windowStyle =
  style
    [ ("position", "absolute")
    , ("display", "block")
    , ("top",  "40%")
    , ("left",  "35%")
    , ("width",  "30%")
    , ("height",  "20%")
    , ("padding",  "16px")
    , ("border",  "16px solid orange")
    , ("background-color",  "white")
    , ("z-index", "1002")
    , ("overflow",  "auto")]

overlayStyle =
  style
  [ ("display", "block"),
    ("position", "absolute"),
    ("left", "0%"),
    ("top", "0%"),
    ("width", "100%"),
    ("height", "100%"),
    ("z-index", "1001"),
    ("background-color", "black"),
    ("opacity",".80"),
    ("-moz-opacity", "0.8"),
    ("filter", "alpha(opacity=80)")
    ]

type alias Context =
  { addTaskAddress : Signal.Address String }

view : Context -> Signal.Address Action -> Model -> Html
view context address model =
  let
    taskInput = textarea
        [ placeholder "Enter task description"
        , value model.taskDescription
        , on "input" targetValue (Signal.message address << TaskDescription)
        , style [("display", "block"), ("width", "100%"), ("margin-bottom", "1em")]
        , rows 4
        ]
        []
    cancelButton = button [onClick address Hide] [text "Cancel"]
    addButton = button [disabled <| String.isEmpty model.taskDescription, onClick context.addTaskAddress model.taskDescription] [text "Add"]
    popupContent = div [] [taskInput, addButton, cancelButton]
  in
    if model.visible
    then
      div []
        [ div [windowStyle] [popupContent]
        , div [overlayStyle] [] ]
    else
      node "noscript" [] []

module TaskBox(Model, withDescription, Action, view) where

import Html exposing (p, Html, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onMouseEnter, onMouseLeave)

-- MODEL

type alias Model =
  { description : String
  , mouseOver : Bool }

withDescription description =
  { description = description
  , mouseOver = False }

-- UPDATE

type Action
  = OnMouseEnter
  | OnMouseLeave

update : Action -> Model -> Model
update action model =
  case action of
    OnMouseEnter -> { model | mouseOver = True }
    OnMouseLeave -> { model | mouseOver = False }


-- VIEW

taskStyle mouseOver =
  style
  [ ("border", if mouseOver then "1px solid red" else "1px solid black")
  , ("margin", "20px 10px")
  , ("cursor", "pointer")]

view : Signal.Address Action -> Model -> Html
view address model =
  let
    enter = onMouseEnter address OnMouseEnter
    leave = onMouseLeave address OnMouseLeave
    attributes = [taskStyle model.mouseOver, enter, leave]
  in
    p attributes [text model.description]

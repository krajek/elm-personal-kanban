module TaskBox(Model, withDescription, Action, view) where

import Html exposing (p, Html, text)
import Html.Attributes exposing (style)

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

taskStyle =
  style
  [ ("border", "1px solid black")
  , ("margin", "20px 10px")
  , ("cursor", "pointer")]

view : Model -> Html
view model =
  p [taskStyle] [text model.description]

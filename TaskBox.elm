module TaskBox(Model, MovePossibility(..), withDescription, Action, update, view) where

import Html exposing (p, Html, text, button)
import Html.Attributes exposing (style)
import Html.Events exposing (onMouseEnter, onMouseLeave, onClick)

-- MODEL

type alias Model =
  { description : String
  , mouseOver : Bool
  , movePossibility : MovePossibility }

type MovePossibility
  = OnlyLeft
  | BothWays
  | OnlyRight

withDescription : String -> MovePossibility -> Model
withDescription description movePossibility =
  { description = description
  , mouseOver = False
  , movePossibility = movePossibility }

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

type alias Context =
  { deleteAddress : Signal.Address () }

view : Context -> Signal.Address Action -> Model -> Html
view context address model =
  let
    enter = onMouseEnter address OnMouseEnter
    leave = onMouseLeave address OnMouseLeave
    attributes = [taskStyle model.mouseOver, enter, leave]
    deleteButtonPart =
      if model.mouseOver
        then [ button [onClick context.deleteAddress ()] [text "X"] ]
        else []
    descriptionPart = [text model.description]
    movePartText =
      case model.movePossibility of
        OnlyLeft -> "left"
        BothWays -> "both"
        OnlyRight -> "right"
    movePart = [text movePartText]
  in
    p attributes <| descriptionPart ++ deleteButtonPart ++ movePart

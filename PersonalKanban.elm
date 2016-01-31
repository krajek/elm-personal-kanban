module PersonalKanban where

import Effects exposing (Effects, none)
import Html exposing (..)
import Task


-- MODEL

type alias Model =
    { columnName : String
    }


init : (Model, Effects Action)
init =
  ( { columnName = "To do" }
  , Effects.none
  )


-- UPDATE

type Action
    = NoOp


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)

-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  div []
  [ h2 [] [text "ABC"]
  ]

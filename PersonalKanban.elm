module PersonalKanban where

import Effects exposing (Effects, none)
import Html exposing (..)
import Html.Attributes exposing (..)
import TaskColumn

-- ACTION

type Action
    = NoOp
    | TaskColumnAction TaskColumn.Action

-- MODEL

type alias Model =
    { columns : List TaskColumn.Model
    }


init : (Model, Effects Action)
init =
  let
    todoColumn = { name = "To Do", tasks = ["Fake task"] }
    inProgressColumn = { name = "In Progress", tasks = ["Fake task"] }
    doneColumn = { name = "Done", tasks = ["Fake task"] }
    model = { columns = [todoColumn, inProgressColumn, doneColumn] }
  in
    ( model, Effects.none )


-- UPDATE

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)

    TaskColumnAction columnAction ->
      (model, Effects.none)

-- VIEW

tableStyle : Attribute
tableStyle =
  style
    [ ("table-layout", "fixed")
    , ("width", "100%")
    , ("height", "100%")
    , ("border-collapse", "collapse") ]

cellStyle : Attribute
cellStyle =
  style
    [("border", "1px solid black")]

view : Signal.Address Action -> Model -> Html
view address model =
  let
    viewColumn column =
        td [cellStyle]
          [ TaskColumn.view (Signal.forwardTo address (TaskColumnAction)) column ]
  in
    table [tableStyle] [tr [] <| List.map viewColumn model.columns]

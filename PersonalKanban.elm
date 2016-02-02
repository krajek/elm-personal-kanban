module PersonalKanban where

import Effects exposing (Effects, none)
import Html exposing (..)
import Html.Attributes exposing (..)
import TaskColumn
import TaskHeader

-- ACTION

type Action
    = NoOp
    | TaskColumnAction TaskColumn.Action

-- MODEL

type alias Model =
    { columns : List (TaskHeader.Model, TaskColumn.Model) }


init : (Model, Effects Action)
init =
  let
    todoColumn = ( {name = "To do" }, { tasks = ["Fake task"] })
    inProgressColumn = ( {name = "In progress" }, { tasks = ["Fake task"] })
    doneColumn = ( {name = "Done"}, { tasks = ["Fake task"] })
    model =
      { columns = [todoColumn, inProgressColumn, doneColumn] }
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

headerStyle : Attribute
headerStyle =
  style
    [("height", "100px")]

view : Signal.Address Action -> Model -> Html
view address model =
  let
    viewHeader headerModel =
      th [] [TaskHeader.view headerModel]
    viewColumnCell column =
        td [cellStyle]
          [ TaskColumn.view (Signal.forwardTo address (TaskColumnAction)) column ]
    headersRow = tr [headerStyle] <| List.map viewHeader (List.map fst model.columns)
    cellsRow = tr [headerStyle] <| List.map viewColumnCell (List.map snd model.columns)
  in
    table [tableStyle] [headersRow, cellsRow]

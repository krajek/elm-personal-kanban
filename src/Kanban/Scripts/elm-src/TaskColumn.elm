module TaskColumn(Action(AddTask, RemoveTask), Position(First, Surrounded, Last), Model, update, Context, view) where

import Html exposing (..)
import Html.Attributes exposing (style)
import TaskBox
import Debug

type Action
  = AddTask Int String
  | TaskBoxAction Int TaskBox.Action
  | RemoveTask Int

type Position
  = First
  | Surrounded
  | Last

type alias Model =
  { tasks : List (Int, TaskBox.Model)
  , position : Position }

update : Action -> Model -> Model
update action model =
  case action of
    AddTask id content ->
      let
        taskMove =
          case model.position of
            First -> TaskBox.OnlyRight
            Last -> TaskBox.OnlyLeft
            Surrounded -> TaskBox.BothWays
        newTask = (id, TaskBox.withDescription content taskMove)
        newModel =
            { model
            | tasks = model.tasks ++ [newTask] }
      in
        newModel

    TaskBoxAction taskId taskBoxAction ->
      let
        updateTask : (Int, TaskBox.Model) -> (Int, TaskBox.Model)
        updateTask (id, task) =
          if taskId == id
            then (id, TaskBox.update taskBoxAction task)
            else (id, task)

        newModel : Model
        newModel =
          { model
          | tasks = List.map updateTask model.tasks }
      in
        newModel

    RemoveTask taskId ->
      { model
      | tasks = List.filter (\(id, task) -> taskId /= id) model.tasks }


type alias Context =
  { moveRightAddress : Signal.Address (Int, String)
  , moveLeftAddress : Signal.Address (Int, String)
  , removeTaskAddress : Signal.Address Int }


view : Context -> Signal.Address Action -> Model -> Html
view context address model =
  let
    viewTask (taskId, task) =
      let
        taskBoxAddress = Signal.forwardTo address <| TaskBoxAction taskId
        taskContext =
          { deleteAddress = Signal.forwardTo context.removeTaskAddress (always taskId)
          , moveLeftAddress = Signal.forwardTo context.moveLeftAddress (\desc -> (taskId, desc))
          , moveRightAddress = Signal.forwardTo context.moveRightAddress (\desc -> (taskId, desc)) }
      in
        TaskBox.view taskContext taskBoxAddress task
    tasks = List.map viewTask model.tasks
  in
    section [] tasks

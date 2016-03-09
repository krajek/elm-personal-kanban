module KanbanBoard.Update(update, init) where

import Effects exposing (Effects, none)
import TaskColumn
import TaskHeader
import TaskBox
import AddTaskPopup
import Task

import KanbanBoard.Model exposing (Model, initColumns)
import KanbanBoard.Action exposing (Action(..), MoveDirection(..))
import KanbanBoard.Effects exposing (removeTask, postNewTask, getTodoTasks)

init : (Model, Effects Action)
init =
  let
    model =
      { columns = initColumns
      , popup = AddTaskPopup.init }
  in
    ( model, getTodoTasks )

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)

    TaskColumnAction columnId columnAction ->
      let
        updateColumn (id, h, c) =
          if id == columnId
            then (id, h, TaskColumn.update columnAction c)
            else (id, h, c)
        newColumns = List.map updateColumn model.columns
        model' =
          { model
          | columns = newColumns }
      in
        (model', Effects.none)
        
    RemoveTaskFromBoardRequest columnId taskId ->
      let
        updateColumn (id, headerModel, columnModel) =
          if id == columnId then
            (id, headerModel, TaskColumn.update (TaskColumn.RemoveTask taskId) columnModel)
          else
            (id, headerModel, columnModel)
        newColumns : List (Int, TaskHeader.Model, TaskColumn.Model)
        newColumns = List.map updateColumn model.columns
        model' : Model
        model' =
          { model
          | columns = newColumns }
      in
        (model', removeTask taskId)

    AddNewTaskToBoardRequest ->
      let
        model' =
          { model
          | popup = AddTaskPopup.update AddTaskPopup.Show model.popup }
      in
        (model', Effects.none)

    AddNewTaskToBoard desc ->
      (model, postNewTask desc) 
        
    AddNewTaskToBoardConfirmed maybeArgs ->
        case maybeArgs of
            Just (desc,taskId) ->
                let
                    updateFirstColumn index (id, headerModel, columnModel) =
                        if index == 0 then
                            (id, headerModel, TaskColumn.update (TaskColumn.AddTask taskId desc) columnModel)
                        else
                            (id, headerModel, columnModel)
                    newColumns : List (Int, TaskHeader.Model, TaskColumn.Model)
                    newColumns = List.indexedMap updateFirstColumn model.columns
                    model' : Model
                    model' =
                        { model
                        | columns = newColumns
                        , popup = AddTaskPopup.update AddTaskPopup.Hide model.popup }
                in
                    (model', Effects.none)
            Nothing -> (model, Effects.none)
                 

    PopupAction popupAction ->
      let
        model' =
          { model
          | popup = AddTaskPopup.update popupAction model.popup }
      in
        (model', Effects.none)

    MoveTask direction columnId (taskId, desc) ->
      let
        targetColumnId =
          case direction of
            Left -> columnId - 1
            Right -> columnId + 1
        newColumns = moveTask model.columns columnId targetColumnId taskId desc
        model' =
          { model
          | columns = newColumns }
      in
        (model', Effects.none)
        
    TasksLoaded maybeNames -> 
        case maybeNames of
            Just names -> 
                let
                    updateFirstColumn index (id, headerModel, columnModel) =
                        if index == 0 then
                            let updateColumnWithNewTasks = 
                                names 
                                |> List.foldl (\(id, name, colId) acc -> TaskColumn.update (TaskColumn.AddTask id name) acc) columnModel
                            in (id, headerModel, updateColumnWithNewTasks)
                        else
                            (id, headerModel, columnModel)
                    newColumns : List (Int, TaskHeader.Model, TaskColumn.Model)
                    newColumns = List.indexedMap updateFirstColumn model.columns
                    model' : Model
                    model' =
                    { model
                    | columns = newColumns
                    , popup = AddTaskPopup.update AddTaskPopup.Hide model.popup }
                in
                    (model', Effects.none)
            Nothing ->
                (model, Effects.none)

moveTask : List (Int, TaskHeader.Model, TaskColumn.Model) -> Int -> Int -> Int -> String -> List (Int, TaskHeader.Model, TaskColumn.Model)
moveTask columns columnId targetColumnId taskId taskDescription =
  let
    addTaskToRightColumn (id, headerModel, columnModel) =
      if id == targetColumnId then
        (id, headerModel, TaskColumn.update (TaskColumn.AddTask taskId taskDescription) columnModel)
      else
        (id, headerModel, columnModel)
    removeFromColumn (id, headerModel, columnModel) =
      if id == columnId then
        (id, headerModel, TaskColumn.update (TaskColumn.RemoveTask taskId) columnModel)
      else
        (id, headerModel, columnModel)
  in
    columns |> List.map (addTaskToRightColumn >> removeFromColumn)
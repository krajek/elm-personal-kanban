module KanbanBoard.Effects(getTodoTasks, postNewTask, removeTask) where

import Effects exposing (Effects, none)
import Http
import Task
import Json.Decode as Json exposing ((:=))

import KanbanBoard.Action exposing (Action(..), TaskData)


getTodoTasks : Effects Action
getTodoTasks =
  Http.get taskModelsDecoder "/api/task"
    |> Task.toMaybe
    |> Task.map TasksLoaded
    |> Effects.task
    
taskModelsDecoder : Json.Decoder (List TaskData)
taskModelsDecoder =
    Json.list taskModelDecoder
    
taskModelDecoder : Json.Decoder TaskData
taskModelDecoder =
    Json.object2 (,)
      ("Id" := Json.int)
      ("Description" := Json.string)
    
postNewTask : String -> Effects Action
postNewTask description =
    let 
        url = "/api/task"
        body = Http.string <| "\"" ++ description ++ "\""
        decoder = Json.object1 identity ("Id" := Json.int)
        httpTask = 
            Http.send Http.defaultSettings
                { verb = "POST"
                , headers = [("Content-Type", "application/json")]
                , url = url
                , body = body
                }
    in
        httpTask
        |> Http.fromJson decoder
        |> Task.toMaybe
        |> Task.map (\maybeTaskId -> 
            maybeTaskId
            |> Maybe.map (\taskId -> (description, taskId))
            |> AddNewTaskToBoardConfirmed)
        |> Effects.task 
        
removeTask : Int -> Effects Action
removeTask taskId =
    let 
        url = "/api/task/"++ (toString taskId)
        body = Http.empty
        decoder = Json.succeed ()
        httpTask = 
            Http.send Http.defaultSettings
                { verb = "DELETE"
                , headers = []
                , url = url
                , body = body
                }
    in
        httpTask
        |> Task.toMaybe
        |> Task.map (always NoOp)
        |> Effects.task 
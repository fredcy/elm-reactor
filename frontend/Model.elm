module Model where

import Json.Decode exposing (..)

import WebSocket
import Html.File

import Debugger.Service as Service
import Debugger.Active as Active
import SideBar.Logs as Logs
import Button
import Debugger.RuntimeApi as API


type alias Model =
  { serviceState : Service.Model
  , sidebarVisible : Bool
  , permitSwaps : Bool
  , restartButtonState : Button.Model
  , playPauseButtonState : Button.Model
  , errorState : ErrorState
  , logsState : Logs.Model
  , swapSocket : Maybe WebSocket.WebSocket
  }


type ErrorState
  = CompilationErrors CompilationErrors
  | MismatchError API.MismatchError
  | NoErrors


initModel : Model
initModel =
  { serviceState = Service.initModel
  , sidebarVisible = True
  , permitSwaps = True
  , restartButtonState = Button.Up
  , playPauseButtonState = Button.Up
  , errorState = NoErrors
  , logsState = Logs.initModel
  , swapSocket = Nothing
  }


type Message
  = SidebarVisible Bool
  | PermitSwaps Bool
  | PlayPauseButtonAction (Button.Message Active.Command)
  | RestartButtonAction (Button.Message Active.Command)
  | LogsMessage Logs.Message
  | ConnectSocket (Maybe WebSocket.WebSocket)
  | ExportSession
  | ImportSession (List Html.File.File)
  | SwapEvent SwapEvent
  | NewServiceState Service.Model
  | ServiceCommand Active.Command
  -- vv `Nothing` here means resetting the mismatch error
  | ActiveMessage Active.MismatchErrorMessage
  | NoOp


type alias CompilationErrors =
  String


type SwapEvent
  = NewModuleEvent API.CompiledElmModule
  | CompilationErrorsEvent CompilationErrors


swapEvent : Decoder SwapEvent
swapEvent =
  oneOf
    [ object2
        (\name code ->
            NewModuleEvent {name=name, code=code})
        ("name" := string)
        ("code" := string)
    , object1
        CompilationErrorsEvent
        ("error" := string)
    ]

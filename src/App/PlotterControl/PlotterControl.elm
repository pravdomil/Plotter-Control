module App.PlotterControl.PlotterControl exposing (..)

import File exposing (File)
import Utils.Interop exposing (Status)


{-| -}
type alias PlotterControl =
    { console : String
    , status : Status
    , file : Maybe ( File, String )
    }


{-| -}
type PlotterControlMsg
    = ConsoleChanged String
    | ConsoleSubmitted
      --
    | LoadFile
    | LoadMarkers
    | SetSensitivity Int
    | PlotFile
      --
    | GotStatus Status
    | GotFile File
    | GotFileContent File String

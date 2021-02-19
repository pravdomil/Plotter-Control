module App.PlotterControl.PlotterControl exposing (..)

import App.PlotterControl.Filename exposing (Filename)
import File exposing (File)
import Utils.HpGl exposing (HpGl)
import Utils.Interop exposing (Status)


type alias PlotterControl =
    { console : String
    , status : Status
    , file :
        Maybe
            { filename : Result String Filename
            , content : HpGl
            }
    }


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

module App.PlotterControl.PlotterControl exposing (..)

import File exposing (File)
import Utils.Interop exposing (Status)


{-| -}
type alias PlotterControl =
    { console : String
    , status : Status
    , file : Maybe File
    }


{-| -}
type PlotterControlMsg
    = ConsoleChanged String
      --
    | SendData String
    | GotStatus Status

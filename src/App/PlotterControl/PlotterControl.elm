module App.PlotterControl.PlotterControl exposing (..)

import Utils.Interop exposing (Status)


{-| -}
type alias PlotterControl =
    { status : Status
    , console : String
    }


{-| -}
type PlotterControlMsg
    = ConsoleChanged String
      --
    | SendData String
    | GotStatus Status

module App.PlotterControl.PlotterControl exposing (..)

import File exposing (File)
import Utils.HpGl exposing (HpGl)
import Utils.Interop exposing (Status)


{-| -}
type alias PlotterControl =
    { console : String
    , status : Status
    , file :
        Maybe
            { filename : Result String Filename
            , content : HpGl
            }
    }


{-| -}
type alias Filename =
    { name : String

    -- -
    , width : Float

    -- x
    , length : Float

    -- x
    , markers : Int

    -- @
    , speed : Int

    -- .dat
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

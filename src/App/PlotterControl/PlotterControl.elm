module App.PlotterControl.PlotterControl exposing (..)

import File exposing (File)
import Utils.Interop exposing (Status)


{-| -}
type alias PlotterControl =
    { console : String
    , status : Status
    , file :
        Maybe
            { name : Result String Filename
            , content : String
            }
    }


{-| -}
type alias Filename =
    { name : String

    -- _
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

module PlotterControl.Queue exposing (..)

import Dict.Any
import Id
import Time


type alias Queue =
    Dict.Any.Dict (Id.Id Item) Item


type alias Item =
    { name : String
    , data : String

    --
    , created : Time.Posix
    }

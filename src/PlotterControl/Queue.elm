module PlotterControl.Queue exposing (..)

import Dict.Any
import Id


type alias Queue =
    Dict.Any.Dict (Id.Id Item) Item


type alias Item =
    { name : String
    , data : String
    }

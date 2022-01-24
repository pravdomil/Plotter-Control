module PlotterControl.Settings exposing (..)

import Length


type alias Settings =
    { preset : Preset
    , copies : Copies
    , copyDistance : Length.Length
    , markerLoading : MarkerLoading
    }


default : Settings
default =
    { preset = Cut
    , copies = Copies 1
    , copyDistance = Length.millimeters 10
    , markerLoading = LoadSequentially
    }



--


type Preset
    = Cut
    | Draw
    | Perforate



--


type Copies
    = Copies Int


copiesPlus : Copies -> Copies -> Copies
copiesPlus (Copies a) (Copies b) =
    a + b |> max 1 |> Copies



--


type MarkerLoading
    = LoadAllAtOnce
    | LoadSequentially

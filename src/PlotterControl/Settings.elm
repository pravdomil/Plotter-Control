module PlotterControl.Settings exposing (..)

import Length


type alias Settings =
    { preset : Preset
    , copies : Copies
    , copyDistance : Length.Length
    , markersLoad : MarkersLoad
    }


default : Settings
default =
    { preset = Cut
    , copies = Copies 1
    , copyDistance = Length.millimeters 10
    , markersLoad = LoadSequentially
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


type MarkersLoad
    = LoadAllAtOnce
    | LoadSequentially

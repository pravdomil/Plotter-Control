module PlotterControl.Settings exposing (..)

import Dict
import Length
import Regex
import SummaEl


type alias Settings =
    { preset : Preset
    , markerLoading : MarkerLoading
    , copies : Copies
    , copyDistance : Length.Length
    }


default : String -> Settings
default name =
    let
        nonAlphaNum : Regex.Regex
        nonAlphaNum =
            Regex.fromString "[^0-9A-Za-z]" |> Maybe.withDefault Regex.never

        words : List String
        words =
            name |> Regex.split nonAlphaNum

        preset : Preset
        preset =
            if List.member "perf" words then
                Perforate

            else if List.member "draw" words then
                Draw

            else
                Cut
    in
    { preset = preset
    , markerLoading = LoadContinually
    , copies = intToCopies 1
    , copyDistance = Length.millimeters 10
    }


loadSettings : SummaEl.Settings -> Settings -> SummaEl.SummaEl
loadSettings additional a =
    loadPreset a.preset
        ++ [ SummaEl.SetSettings
                (Dict.empty
                    |> Dict.insert "OPOS_PANELLING"
                        (case a.markerLoading of
                            LoadContinually ->
                                "ON"

                            LoadSimultaneously ->
                                "OFF"
                        )
                    |> Dict.insert "RECUT_OFFSET"
                        (a.copyDistance
                            |> Length.inMillimeters
                            |> round
                            |> String.fromInt
                        )
                    |> Dict.union additional
                )
           ]



--


type Preset
    = Draw
    | Cut
    | Perforate


allPresets : List Preset
allPresets =
    [ Draw
    , Cut
    , Perforate
    ]


presetName : Preset -> String
presetName a =
    case a of
        Draw ->
            "Draw"

        Cut ->
            "Cut"

        Perforate ->
            "Perforate"


loadPreset : Preset -> SummaEl.SummaEl
loadPreset a =
    [ SummaEl.SetSettings
        (Dict.singleton
            "CONFIGUSER"
            (case a of
                Draw ->
                    "1"

                Cut ->
                    "2"

                Perforate ->
                    "3"
            )
        )
    , SummaEl.UnknownCommand (SummaEl.Restore "NVRAM")
    ]


savePreset : SummaEl.Settings -> Preset -> SummaEl.SummaEl
savePreset settings preset =
    loadPreset preset
        ++ [ SummaEl.SetSettings (settings |> Dict.remove "CONFIGUSER")
           , SummaEl.UnknownCommand (SummaEl.Store "NVRAM")
           ]



--


type Copies
    = Copies Int


intToCopies : Int -> Copies
intToCopies =
    Copies


copiesToInt : Copies -> Int
copiesToInt (Copies a) =
    a


copiesPlus : Copies -> Copies -> Copies
copiesPlus (Copies a) (Copies b) =
    a + b |> max 1 |> intToCopies



--


type MarkerLoading
    = LoadContinually
    | LoadSimultaneously



--


defaultSettings : SummaEl.Settings
defaultSettings =
    [ ( "KNIFE_PRESSURE", "90" )
    , ( "PEN_PRESSURE", "40" )
    , ( "DRAG_OFFSET", "45" )
    , ( "VELOCITY", "700" )
    , ( "OVERCUT", "1" )
    , ( "CONCATENATION", "0" )
    , ( "OPTICUT", "OFF" )
    , ( "SMOOTHING", "OFF" )
    , ( "EMULATION", "AUTO" )
    , ( "TOOL", "DRAG_KNIFE" )
    , ( "MENU_UNITS", "METRIC" )
    , ( "TOOL_COMMANDS", "ACCEPT" )
    , ( "AUTOLOAD", "ON" )
    , ( "SPECIAL_LOAD", "OPOS" )
    , ( "OPOS_SHEET_MODE", "OFF" )
    , ( "OPOS_PANELLING", "ON" )
    , ( "OPOS_ORIGIN", "MARK" )
    , ( "FLEX_CUT", "OFF" )
    , ( "FULL_PRESSURE", "180" )
    , ( "CUT_LENGTH", "400" )
    , ( "FLEX_PRESSURE", "100" )
    , ( "FLEX_LENGTH", "40" )
    , ( "FLEX_VELOCITY", "AUTO" )
    , ( "CONFIGUSER", "1" )
    , ( "MEDIA_SENSE", "ON" )
    , ( "MARKER_X_DIS", "6500" )
    , ( "MARKER_Y_DIS", "18600" )
    , ( "MARKER_X_SIZE", "120" )
    , ( "MARKER_Y_SIZE", "120" )
    , ( "MARKER_X_N", "3" )
    , ( "40G_PRESSURE", "14" )
    , ( "400G_PRESSURE", "94" )
    , ( "DRAG_LANDING", "13" )
    , ( "PEN_LANDING", "12" )
    , ( "TANG_LANDING", "14" )
    , ( "RECUT_OFFSET", "40" )
    , ( "CUTMEDIA_OFFSET", "10" )
    , ( "LANGUAGE", "ENGLISH" )
    , ( "POUNC_PRESSURE", "120" )
    , ( "POUNC_GAP", "1" )
    , ( "OPOS_LEVEL", "60" )
    , ( "OPOS_GREY", "30" )
    , ( "OPOS_BLACK", "150" )
    , ( "UP_VELOCITY", "AUTO" )
    , ( "UP_ACCELERATION_", "AUTO" )
    , ( "DOWN_ACCELERATION_", "AUTO" )
    , ( "TURBOCUT", "OFF" )
    , ( "PANELLING", "OFF" )
    , ( "PANELLING_SIZE", "50" )
    , ( "PANEL_REPLOT", "0" )
    , ( "SORTING_ENABLE", "OFF" )
    ]
        |> Dict.fromList

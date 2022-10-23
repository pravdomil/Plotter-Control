module PlotterControl.Settings exposing (..)

import Dict
import HpGl
import Length
import SummaEl


type alias Settings =
    { preset : Preset
    , markerLoading : MarkerLoading
    , copies : Copies
    , copyDistance : Length.Length
    }


default : Settings
default =
    { preset = Cut
    , markerLoading = LoadSequentially
    , copies = intToCopies 1
    , copyDistance = Length.millimeters 10
    }


toSettings : Settings -> { settings : SummaEl.Settings, recut : SummaEl.SummaEl }
toSettings a =
    let
        settings : Dict.Dict String String
        settings =
            defaultSettings
                |> Dict.insert "TOOL"
                    (case a.preset of
                        Cut ->
                            "DRAG_KNIFE"

                        Draw ->
                            "PEN"

                        Perforate ->
                            "DRAG_KNIFE"
                    )
                |> Dict.insert "FLEX_CUT"
                    (case a.preset of
                        Cut ->
                            "OFF"

                        Draw ->
                            "OFF"

                        Perforate ->
                            "MODE2"
                    )
                |> Dict.insert "FULL_PRESSURE" "400"
                |> Dict.insert "CUT_LENGTH" (Length.millimeters 4 |> HpGl.lengthToString)
                |> Dict.insert "FLEX_PRESSURE" "180"
                |> Dict.insert "FLEX_LENGTH" (Length.millimeters 2.6 |> HpGl.lengthToString)
                |> Dict.insert "FLEX_VELOCITY" "100"
                |> Dict.insert "OPOS_PANELLING"
                    (case a.markerLoading of
                        LoadAllAtOnce ->
                            "OFF"

                        LoadSequentially ->
                            "ON"
                    )
                |> Dict.insert "RECUT_OFFSET"
                    (a.copyDistance
                        |> Length.inMillimeters
                        |> round
                        |> String.fromInt
                    )
                --
                |> Dict.insert "OVERCUT" "2"
                |> Dict.remove "OPOS_LEVEL"
                |> Dict.remove "KNIFE_PRESSURE"
                |> Dict.remove "PEN_PRESSURE"
                |> Dict.remove "DRAG_OFFSET"
                |> Dict.remove "VELOCITY"
    in
    { settings = settings
    , recut =
        a.copies
            |> copiesToInt
            |> (\x ->
                    if x > 1 then
                        [ SummaEl.Recut (x - 1)
                        ]

                    else
                        []
               )
    }



--


type Preset
    = Cut
    | Draw
    | Perforate



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
    = LoadAllAtOnce
    | LoadSequentially



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

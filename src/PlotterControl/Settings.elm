module PlotterControl.Settings exposing (..)

import Dict
import Length
import SummaEL


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
    , markerLoading = LoadAllAtOnce
    }


toCommands : Settings -> ( SummaEL.SummaEL, SummaEL.SummaEL )
toCommands a =
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
                |> Dict.insert "RECUT_OFFSET"
                    (a.copyDistance
                        |> Length.inMillimeters
                        |> round
                        |> String.fromInt
                    )
                |> Dict.insert "OPOS_PANELLING"
                    (case a.markerLoading of
                        LoadAllAtOnce ->
                            "OFF"

                        LoadSequentially ->
                            "ON"
                    )
    in
    ( [ SummaEL.SetSettings settings
      ]
    , a.copies
        |> (\(Copies v) -> v)
        |> (\v ->
                if v > 1 then
                    [ SummaEL.Recut (v - 1)
                    ]

                else
                    []
           )
    )



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



--


defaultSettings : SummaEL.Settings
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

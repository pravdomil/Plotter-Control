module SummaEL exposing (..)

{-| Summa Encapsulated Language
-}

import Dict
import Point2d
import Quantity


type alias SummaEL =
    List Command


toString : SummaEL -> String
toString a =
    a
        |> List.map commandToString
        |> String.join "\n"
        |> (\v -> "\u{001B};@:\n" ++ v ++ "\nEND\n")



--


type Command
    = ReadSettings
    | SetSettings Settings
      --
    | ReadSystemSettings
    | SetSystemSettings SystemSettings
      --
    | CameraExtendedLoad
    | CameraOrigin
    | LoadMarkers
    | Recut Int
    | Report
    | SetOrigin Point
      --
    | UnknownCommand UnknownCommand


commandToString : Command -> String
commandToString a =
    case a of
        ReadSettings ->
            "MENU"

        SetSettings b ->
            settingsToString b

        ReadSystemSettings ->
            "SYS_MENU"

        SetSystemSettings b ->
            systemSettingsToString b

        CameraExtendedLoad ->
            "EXTENDED_LOAD"

        CameraOrigin ->
            "SET_CAM_ORIGIN"

        LoadMarkers ->
            "LOAD_MARKERS"

        Recut b ->
            "RECUT " ++ String.fromInt b

        Report ->
            "QUERY"

        SetOrigin b ->
            "SET_ORIGIN=" ++ pointToString b

        UnknownCommand b ->
            unknownCommandToString b



--


type UnknownCommand
    = ActivateBarcode
    | CalibrateAxes
    | ReadLanguage
    | ReadLastFile
    | ReadMarkers
    | ReadMediaSensors
    | ReloadMarkers
    | Restore
    | SetLanguage
    | SetSerial
    | Store
    | SweepMediaSensors
    | UpgradeFlash


unknownCommandToString : UnknownCommand -> String
unknownCommandToString a =
    case a of
        ActivateBarcode ->
            "ACTIVATE_BARCODE"

        CalibrateAxes ->
            "CAL_AXES_LOGI2"

        ReadLanguage ->
            "READ_LANGUAGE"

        ReadLastFile ->
            "READ_LAST_FILE"

        ReadMarkers ->
            "READ_MARKERS"

        ReadMediaSensors ->
            "READ_MEDIA_SENSORS"

        ReloadMarkers ->
            "RELOAD_MARKERS"

        Restore ->
            "RESTORE"

        SetLanguage ->
            "WRITE_LANGUAGE"

        SetSerial ->
            "SET_SERIAL"

        Store ->
            "STORE"

        SweepMediaSensors ->
            "SWEEP_MEDIA_SENSORS"

        UpgradeFlash ->
            "UPGRADE_FLASH"



--


type alias Settings =
    Dict.Dict String String


settingsToString : Settings -> String
settingsToString a =
    a
        |> Dict.toList
        |> List.map (\( k, v ) -> "SET " ++ k ++ "=" ++ v)
        |> String.join "\n"



--


type alias SystemSettings =
    Dict.Dict String String


systemSettingsToString : SystemSettings -> String
systemSettingsToString a =
    a
        |> Dict.toList
        |> List.map (\( k, v ) -> "SETSYS " ++ k ++ "=" ++ v)
        |> String.join "\n"



--


type alias Point =
    Point2d.Point2d Quantity.Unitless ()


pointToString : Point -> String
pointToString a =
    (a |> Point2d.xCoordinate |> Quantity.toFloat |> String.fromFloat)
        ++ ","
        ++ (a |> Point2d.yCoordinate |> Quantity.toFloat |> String.fromFloat)

module SummaEl exposing (..)

{-| Summa Encapsulated Language
-}

import Dict
import Length
import Point2d
import Quantity


type alias SummaEl =
    List Command


toString : SummaEl -> String
toString a =
    a
        |> List.map commandToString
        |> String.join "\n"
        |> (\x -> "\u{001B};@:\n" ++ x ++ "\nEND\n")



--


type Command
    = ReadSettings
    | SetSettings Settings
      --
    | ReadSystemSettings
    | SetSystemSettings SystemSettings
      --
    | CameraExtendedLoad
    | SetCameraOrigin
    | LoadMarkers
    | Recut Int
    | Report
    | SetOriginRelative Point
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

        SetCameraOrigin ->
            "SET_CAM_ORIGIN"

        LoadMarkers ->
            "LOAD_MARKERS"

        Recut b ->
            "RECUT " ++ String.fromInt b

        Report ->
            "QUERY"

        SetOriginRelative b ->
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
    | Store String
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

        Store b ->
            "STORE " ++ b

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
    Point2d.Point2d Length.Meters ()


pointToString : Point -> String
pointToString a =
    (a |> Point2d.xCoordinate |> lengthToString)
        ++ ","
        ++ (a |> Point2d.yCoordinate |> lengthToString)



--


lengthToString : Length.Length -> String
lengthToString a =
    a
        |> Quantity.at resolution
        |> Quantity.toFloat
        |> round
        |> String.fromInt


resolution : Quantity.Quantity Float (Quantity.Rate Quantity.Unitless Length.Meters)
resolution =
    Quantity.rate (Quantity.float 1) (Length.millimeters 0.025)

module Utils.SummaCommand exposing (..)

import Utils.HpGl exposing (HpGl)


{-| -}
type SummaCommand
    = Query
      --
    | Menu
    | SysMenu
      --
    | Set String
    | SetSys String
      --
    | LoadMarkers
    | ReloadMarkers
    | ReadMarkers
      --
    | ActivateBarcode
      --
    | ReadMediaSensors
    | SweepMediaSensors
      --
    | ReadLastFile
    | Recut
      --
    | SetOrigin
      --
    | Store
    | Restore
      --
    | ReadLanguage
    | WriteLanguage
      --
    | SetSerial
      --
    | CalAxesLogi2
      --
    | UpgradeFlash
      --
    | End


{-| -}
toHpGl : SummaCommand -> HpGl
toHpGl a =
    listToHpGl [ a ]


{-| -}
listToHpGl : List SummaCommand -> HpGl
listToHpGl a =
    []
        ++ [ "\u{001B};@:" ]
        ++ (a |> List.map toString)
        ++ [ "END" ]
        |> String.join "\n"
        |> HpGl.fromString


{-| To convert command to string.
-}
toString : SummaCommand -> String
toString a =
    case a of
        Query ->
            "QUERY"

        Menu ->
            "MENU"

        SysMenu ->
            "SYS_MENU"

        Set b ->
            "SET " ++ b

        SetSys b ->
            "SETSYS " ++ b

        LoadMarkers ->
            "LOAD_MARKERS"

        ReloadMarkers ->
            "RELOAD_MARKERS"

        ReadMarkers ->
            "READ_MARKERS"

        ActivateBarcode ->
            "ACTIVATE_BARCODE"

        ReadMediaSensors ->
            "READ_MEDIA_SENSORS"

        SweepMediaSensors ->
            "SWEEP_MEDIA_SENSORS"

        ReadLastFile ->
            "READ_LAST_FILE"

        Recut ->
            "RECUT"

        SetOrigin ->
            "SET_ORIGIN"

        Store ->
            "STORE"

        Restore ->
            "RESTORE"

        ReadLanguage ->
            "READ_LANGUAGE"

        WriteLanguage ->
            "WRITE_LANGUAGE"

        SetSerial ->
            "SET_SERIAL"

        CalAxesLogi2 ->
            "CAL_AXES_LOGI2"

        UpgradeFlash ->
            "UPGRADE_FLASH"

        End ->
            "END"

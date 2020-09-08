module Utils.Summa exposing (..)

{-| -}


{-| To define summa commands.
-}
type Command
    = Query
      --
    | Menu
    | SysMenu
      --
    | Set string
    | Setsys
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


{-| To send command.
-}
sendCommand : Command -> String
sendCommand a =
    "\u{001B};@:\n" ++ (a |> commandToString) ++ "\nEND\n"


{-| To convert command to string.
-}
commandToString : Command -> String
commandToString a =
    case a of
        Query ->
            "QUERY"

        Menu ->
            "MENU"

        Set a ->
            "SET " ++ a

        SysMenu ->
            "SYS_MENU"

        Setsys ->
            "SETSYS"

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

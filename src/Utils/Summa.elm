module Utils.Summa exposing (..)

{-| -}


{-| To define summa commands.
-}
type Command
    = QUERY
      --
    | MENU
    | SYS_MENU
      --
    | SET String
    | SETSYS
      --
    | LOAD_MARKERS
    | RELOAD_MARKERS
    | READ_MARKERS
      --
    | ACTIVATE_BARCODE
      --
    | READ_MEDIA_SENSORS
    | SWEEP_MEDIA_SENSORS
      --
    | READ_LAST_FILE
    | RECUT
      --
    | SET_ORIGIN
      --
    | STORE
    | RESTORE
      --
    | READ_LANGUAGE
    | WRITE_LANGUAGE
      --
    | SET_SERIAL
      --
    | CAL_AXES_LOGI2
      --
    | UPGRADE_FLASH
      --
    | END


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
        QUERY ->
            "QUERY"

        MENU ->
            "MENU"

        SET a ->
            "SET " ++ a

        SYS_MENU ->
            "SYS_MENU"

        SETSYS ->
            "SETSYS"

        LOAD_MARKERS ->
            "LOAD_MARKERS"

        RELOAD_MARKERS ->
            "RELOAD_MARKERS"

        READ_MARKERS ->
            "READ_MARKERS"

        ACTIVATE_BARCODE ->
            "ACTIVATE_BARCODE"

        READ_MEDIA_SENSORS ->
            "READ_MEDIA_SENSORS"

        SWEEP_MEDIA_SENSORS ->
            "SWEEP_MEDIA_SENSORS"

        READ_LAST_FILE ->
            "READ_LAST_FILE"

        RECUT ->
            "RECUT"

        SET_ORIGIN ->
            "SET_ORIGIN"

        STORE ->
            "STORE"

        RESTORE ->
            "RESTORE"

        READ_LANGUAGE ->
            "READ_LANGUAGE"

        WRITE_LANGUAGE ->
            "WRITE_LANGUAGE"

        SET_SERIAL ->
            "SET_SERIAL"

        CAL_AXES_LOGI2 ->
            "CAL_AXES_LOGI2"

        UPGRADE_FLASH ->
            "UPGRADE_FLASH"

        END ->
            "END"

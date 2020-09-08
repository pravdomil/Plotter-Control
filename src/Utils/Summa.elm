module Utils.Summa exposing (..)

{-| -}


{-| To define summa commands.
-}
type Commands
    = QUERY
      --
    | MENU
    | SET
    | SYS_MENU
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

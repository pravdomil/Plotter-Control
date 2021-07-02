module PlotterControl.Data.Summa exposing (..)


type alias Summa =
    List Command


type Command
    = DeviceInfo
      --
    | ShowMenu
    | ShowSystemMenu
      --
    | SetValue Value
    | SetSystemValue SystemValue
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
    | Recut Int
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


type Value
    = Raw String String
    | FlexCut FlexCut
    | MarkerXDistance Float
    | MarkerXCount Int
    | MarkerYDistance Float
    | Tool Tool
    | Velocity Int


type FlexCut
    = Off
    | Fast
    | Accurate


type Tool
    = Pen
    | Knife
    | Pouncer


type SystemValue
    = Raw_ String String



--


toString : Summa -> String
toString a =
    ([ "\u{001B};@:" ] ++ (a |> List.map commandToString) ++ [ "END", "" ])
        |> String.join "\n"


commandToString : Command -> String
commandToString a =
    case a of
        DeviceInfo ->
            "QUERY"

        ShowMenu ->
            "MENU"

        ShowSystemMenu ->
            "SYS_MENU"

        SetValue b ->
            "SET " ++ valueToString b

        SetSystemValue b ->
            "SETSYS " ++ systemValueToString b

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

        Recut b ->
            "RECUT " ++ String.fromInt b

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


valueToString : Value -> String
valueToString a =
    (case a of
        Raw k v ->
            [ k, v ]

        FlexCut b ->
            [ "FLEX_CUT"
            , case b of
                Off ->
                    "OFF"

                Fast ->
                    "MODE1"

                Accurate ->
                    "MODE2"
            ]

        MarkerXDistance b ->
            [ "MARKER_X_DIS", String.fromInt (round (b * 40)) ]

        MarkerXCount b ->
            [ "MARKER_X_N", String.fromInt b ]

        MarkerYDistance b ->
            [ "MARKER_Y_DIS", String.fromInt (round (b * 40)) ]

        Tool b ->
            [ "TOOL"
            , case b of
                Pen ->
                    "PEN"

                Knife ->
                    "DRAG_KNIFE"

                Pouncer ->
                    "POUNCER"
            ]

        Velocity b ->
            [ "VELOCITY", String.fromInt b ]
    )
        |> String.join "="


systemValueToString : SystemValue -> String
systemValueToString a =
    case a of
        Raw_ k v ->
            k ++ "=" ++ v

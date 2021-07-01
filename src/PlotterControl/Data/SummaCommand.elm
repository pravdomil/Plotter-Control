module PlotterControl.Data.SummaCommand exposing (..)

import PlotterControl.Data.PlotData as PlotData exposing (PlotData)


type SummaCommand
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


type Value
    = Raw String String
    | FlexCut Bool
    | MarkerXDistance Float
    | MarkerXCount Int
    | MarkerYDistance Float
    | Tool Tool
    | Velocity Int


type Tool
    = Pen
    | Knife
    | Pouncer


type SystemValue
    = Raw String String



--


toPlotData : SummaCommand -> PlotData
toPlotData a =
    listToPlotData [ a ]


listToPlotData : List SummaCommand -> PlotData
listToPlotData a =
    ([ "\u{001B};@:" ] ++ (a |> List.map toString) ++ [ "END", "" ])
        |> String.join "\n"
        |> PlotData.fromString


toString : SummaCommand -> String
toString a =
    case a of
        DeviceInfo ->
            "QUERY"

        ShowMenu ->
            "MENU"

        ShowSystemMenu ->
            "SYS_MENU"

        SetValue b ->
            "SET " ++ b

        SetSystemValue b ->
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

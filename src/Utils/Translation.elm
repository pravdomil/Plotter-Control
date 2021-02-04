module Utils.Translation exposing (..)

import Utils.Interop exposing (Status(..))


{-| -}
type Translation
    = A_Title
    | A_Raw String
      --
    | ConnectToPlotter
    | ConnectingToPlotter
    | ConnectedButtonLabel
      --
    | LoadFile
    | SendingData
      --
    | LoadMarkers
    | Cut
      --
    | XOffset
    | YOffset
      --
    | Status_Ready
    | Status_Connecting
    | Status_Idle
    | Status_Busy
    | Status_Error String


{-| -}
t : Translation -> String
t a =
    case a of
        A_Title ->
            "Plotter Control"

        A_Raw b ->
            b

        --
        ConnectToPlotter ->
            "Connect to Plotter"

        ConnectingToPlotter ->
            "Connecting..."

        ConnectedButtonLabel ->
            "Connected"

        --
        LoadFile ->
            "Load File"

        SendingData ->
            "Sending Data..."

        --
        LoadMarkers ->
            "Load Markers"

        Cut ->
            "Cut"

        --
        XOffset ->
            "X Offset:"

        YOffset ->
            "Y Offset:"

        --
        Status_Ready ->
            "Ready"

        Status_Connecting ->
            "Connecting"

        Status_Idle ->
            "Idle"

        Status_Busy ->
            "Busy"

        Status_Error b ->
            "Error: " ++ b



--


{-| -}
status : Status -> Translation
status a =
    case a of
        Ready ->
            Status_Ready

        Connecting ->
            Status_Connecting

        Idle ->
            Status_Idle

        Busy ->
            Status_Busy

        Error b ->
            Status_Error b

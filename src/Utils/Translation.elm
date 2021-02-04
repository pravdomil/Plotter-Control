module Utils.Translation exposing (..)

{-| -}


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

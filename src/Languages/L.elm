module Languages.L exposing (..)

import String exposing (fromInt)


pageTitle =
    "Plotter Control"


connectToPlotter =
    "Connect to Plotter"


connectingToPlotter =
    "Connecting..."


choosePlotFile =
    "Choose Plot File"


plotButton i =
    if i == 0 then
        "Plot Nothing"

    else if i == 1 then
        "Plot 1 Item"

    else
        "Plot " ++ fromInt i ++ " Items"


plotterNotes =
    "Note: Speed, pressure and offset can be set only by using plotter panel."

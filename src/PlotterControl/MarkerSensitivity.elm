module PlotterControl.MarkerSensitivity exposing (..)

import Quantity


type alias MarkerSensitivity =
    Quantity.Quantity Int MarkerSensitivity_


toString : MarkerSensitivity -> String
toString a =
    String.fromInt (Quantity.unwrap a) ++ " %"



--


type MarkerSensitivity_
    = MarkerSensitivity_

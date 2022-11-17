module PlotterControl.MarkerSensitivity exposing (..)

import Quantity


type alias MarkerSensitivity =
    Quantity.Quantity Int MarkerSensitivity_


fromInt : Int -> MarkerSensitivity
fromInt a =
    Quantity.unsafe a


toInt : MarkerSensitivity -> Int
toInt a =
    Quantity.unwrap a


toString : MarkerSensitivity -> String
toString a =
    String.fromInt (toInt a) ++ " %"



--


type MarkerSensitivity_
    = MarkerSensitivity_

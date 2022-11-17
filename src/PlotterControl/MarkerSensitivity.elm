module PlotterControl.MarkerSensitivity exposing (..)

import Quantity


type alias MarkerSensitivity =
    Quantity.Quantity Int MarkerSensitivity_


percentage : Int -> MarkerSensitivity
percentage a =
    Quantity.unsafe a


inPercentage : MarkerSensitivity -> Int
inPercentage a =
    Quantity.unwrap a


toString : MarkerSensitivity -> String
toString a =
    String.fromInt (inPercentage a) ++ " %"



--


type MarkerSensitivity_
    = MarkerSensitivity_

module PlotterControl.Utils.Utils exposing (..)

import Length


layerCutPressure : Int
layerCutPressure =
    100


mmToString : Length.Length -> String
mmToString a =
    a
        |> Length.inMillimeters
        |> (*) 10
        |> round
        |> toFloat
        |> (\x -> x / 10)
        |> String.fromFloat
        |> (\x -> x ++ " mm")

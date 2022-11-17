module PlotterControl.Utils.Utils exposing (..)

import Length
import Mass
import Speed


layerCutPressure : Mass.Mass
layerCutPressure =
    Mass.grams 100


lengthToString : Length.Length -> String
lengthToString a =
    a
        |> Length.inMillimeters
        |> (*) 10
        |> round
        |> toFloat
        |> (\x -> x / 10)
        |> String.fromFloat
        |> (\x -> x ++ " mm")


speedToString : Speed.Speed -> String
speedToString a =
    String.fromInt (round (Speed.inMetersPerSecond a / 1000)) ++ " mm/s"


massToString : Mass.Mass -> String
massToString a =
    String.fromInt (round (Mass.inGrams a)) ++ " g"



--


millimetersPerSecond : Float -> Speed.Speed
millimetersPerSecond a =
    Speed.metersPerSecond (a / 1000)


inMillimetersPerSecond : Speed.Speed -> Float
inMillimetersPerSecond a =
    Speed.inMetersPerSecond a / 1000

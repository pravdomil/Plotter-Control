module PlotterControl.Data.HpGl exposing (..)

import PlotterControl.Data.PlotData as PlotData exposing (PlotData)


{-| <https://en.wikipedia.org/wiki/HP-GL>
-}
type HpGl
    = HpGl String


fromString : String -> HpGl
fromString =
    HpGl


toString : HpGl -> String
toString (HpGl a) =
    a


toPlotData : HpGl -> PlotData
toPlotData (HpGl a) =
    PlotData.fromString a


append : HpGl -> HpGl -> HpGl
append (HpGl a) (HpGl b) =
    a ++ b |> HpGl

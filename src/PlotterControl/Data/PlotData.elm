module PlotterControl.Data.PlotData exposing (..)


type PlotData
    = PlotData String


toString : PlotData -> String
toString (PlotData a) =
    a

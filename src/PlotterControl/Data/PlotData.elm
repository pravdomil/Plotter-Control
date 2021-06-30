module PlotterControl.Data.PlotData exposing (..)


type PlotData
    = PlotData String


fromString : String -> PlotData
fromString =
    PlotData


toString : PlotData -> String
toString (PlotData a) =
    a

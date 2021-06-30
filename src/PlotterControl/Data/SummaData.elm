module PlotterControl.Data.SummaData exposing (..)


type SummaData
    = SummaData String


toString : SummaData -> String
toString (SummaData a) =
    a

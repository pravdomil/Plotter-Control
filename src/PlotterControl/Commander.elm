module PlotterControl.Commander exposing (..)


type alias Commander =
    { type_ : CommandType
    , command : String
    }



--


type CommandType
    = Raw
    | SummaEncapsulatedLanguage

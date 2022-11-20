module PlotterControl.Commander exposing (..)


type alias Commander =
    { type_ : CommandType
    , command : String
    }



--


type CommandType
    = Raw
    | SummaEncapsulatedLanguage


allCommandTypes : List CommandType
allCommandTypes =
    [ Raw
    , SummaEncapsulatedLanguage
    ]


commandTypeToName : CommandType -> String
commandTypeToName a =
    case a of
        Raw ->
            "Raw"

        SummaEncapsulatedLanguage ->
            "Summa Language"

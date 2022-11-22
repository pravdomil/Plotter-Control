module PlotterControl.Commander exposing (..)

import Length


type alias Commander =
    { type_ : CommandType
    , command : String

    --
    , sensorLeftOffset : Length.Length
    , sensorUpOffset : Length.Length
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

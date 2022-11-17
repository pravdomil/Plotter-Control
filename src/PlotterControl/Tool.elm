module PlotterControl.Tool exposing (..)


type Tool
    = Commander


toName : Tool -> String
toName a =
    case a of
        Commander ->
            "Commander"


all : List Tool
all =
    [ Commander
    ]

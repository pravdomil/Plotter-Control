module PlotterControl.Filename exposing (..)

import Parser as P exposing ((|.), (|=), Parser)
import PlotterControl.Data.PlotData as PlotData exposing (PlotData)
import PlotterControl.Data.SummaCommand as SummaCommand


type alias Filename =
    { name : String
    , markers :
        Maybe
            { x : Float
            , y : Float
            , count : Int
            }
    , speed : Maybe Int
    , copies : Maybe Int
    , tool : Maybe Tool
    , flex : Maybe Bool
    , format : Format
    }


type Tool
    = Pen
    | Knife
    | Pounce


type Format
    = Dmpl
    | HpGL


format : String
format =
    "<Name> [<HorizontalMarkerDistance>x<VerticalMarkerDistance>x<NumberOfMarkers>] [<Speed>mms] [<Copies>x] [pen|knife|pounce] [const|flex].[dmpl|hpgl]"


fromString : String -> Result (List P.DeadEnd) Filename
fromString a =
    P.run parser a


toPlotData : Filename -> ( PlotData, PlotData )
toPlotData a =
    let
        prefix : PlotData
        prefix =
            [ "MARKER_X_SIZE=" ++ String.fromInt (3 * 40)
            , "MARKER_Y_SIZE=" ++ String.fromInt (3 * 40)

            --
            , "MARKER_Y_DIS=" ++ String.fromFloat (a.markerDistanceX * 40)
            , "MARKER_X_DIS=" ++ String.fromFloat (a.markerDistanceY * 40)
            , "MARKER_X_N=" ++ String.fromInt a.markerCount

            --
            , "VELOCITY=" ++ String.fromInt a.speed
            , "FLEX_CUT=" ++ onOff a.perforation
            ]
                |> List.map SummaCommand.Set
                |> SummaCommand.listToPlotData

        postfix : PlotData
        postfix =
            SummaCommand.Recut
                |> SummaCommand.toPlotData
                |> PlotData.toString
                |> String.repeat (a.copies - 1)
                |> PlotData.fromString

        onOff : Bool -> String
        onOff b =
            if b then
                "ON"

            else
                "OFF"
    in
    ( prefix, postfix )



--


parser : Parser Filename
parser =
    P.succeed Filename
        |= P.getChompedString (P.chompUntil "-")
        |. P.symbol "-"
        |= P.float
        |. P.symbol "x"
        |= P.float
        |. P.symbol "x"
        |= P.int
        |. P.symbol "@"
        |= P.int
        |. P.symbol "x"
        |= P.int
        |= P.oneOf
            [ P.succeed False
                |. P.symbol "cut"
            , P.succeed True
                |. P.symbol "perf"
            ]
        |. P.symbol ".hpgl"
        |. P.end

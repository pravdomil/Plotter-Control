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
    , cut : Maybe Cut
    , format : Format
    }


type Tool
    = Pen
    | Knife
    | Pounce


type Cut
    = ConstCut
    | FlexCut


type Format
    = Dmpl
    | HpGL


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


format : String
format =
    "<Name> [<HorizontalMarkerDistance>x<VerticalMarkerDistance>x<NumberOfMarkers>] [<Speed>mms] [<Copies>x] [pen|knife|pounce] [const|flex].[dmpl|hpgl]"


parser : Parser Filename
parser =
    let
        argEnd : Parser ()
        argEnd =
            P.oneOf
                [ P.symbol " "
                , P.symbol "."
                ]

        chompOneOrMoreIf : (Char -> Bool) -> Parser ()
        chompOneOrMoreIf v =
            P.chompIf v |. P.chompWhile v
    in
    P.succeed Filename
        |= P.getChompedString (chompOneOrMoreIf (\v -> v /= ' ' && v /= '.'))
        |. argEnd
        |= P.oneOf
            [ P.succeed
                (\x y count ->
                    Just
                        { x = x
                        , y = y
                        , count = count
                        }
                )
                |= P.float
                |. P.symbol "x"
                |= P.float
                |. P.symbol "x"
                |= P.int
                |. argEnd
            , P.succeed
                Nothing
            ]
        |= P.oneOf
            [ P.succeed Just
                |= P.int
                |. P.symbol "mms"
                |. argEnd
            , P.succeed
                Nothing
            ]
        |= P.oneOf
            [ P.succeed Just
                |= P.int
                |. P.symbol "x"
                |. argEnd
            , P.succeed
                Nothing
            ]
        |= P.oneOf
            [ P.succeed (Just Pen)
                |. P.symbol "pen"
                |. argEnd
            , P.succeed (Just Knife)
                |. P.symbol "knife"
                |. argEnd
            , P.succeed (Just Pounce)
                |. P.symbol "pounce"
                |. argEnd
            , P.succeed
                Nothing
            ]
        |= P.oneOf
            [ P.succeed (Just ConstCut)
                |. P.symbol "const"
                |. argEnd
            , P.succeed (Just FlexCut)
                |. P.symbol "flex"
                |. argEnd
            , P.succeed
                Nothing
            ]
        |= P.oneOf
            [ P.succeed Dmpl
                |. P.symbol "dmpl"
                |. P.end
            , P.succeed HpGL
                |. P.symbol "hpgl"
                |. P.end
            ]

module PlotterControl.Filename exposing (..)

import Parser as P exposing ((|.), (|=), Parser)
import PlotterControl.Data.PlotData as PlotData exposing (PlotData)
import PlotterControl.Data.Summa as Summa


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
    , tool : Maybe Summa.Tool
    , cut : Maybe Cut
    , format : Format
    }


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
            [ a.markers
                |> Maybe.map
                    (\v ->
                        [ Summa.SetValue (Summa.MarkerYDistance v.x)
                        , Summa.SetValue (Summa.MarkerXDistance v.y)
                        , Summa.SetValue (Summa.MarkerXCount v.count)
                        ]
                    )
            , a.speed
                |> Maybe.map
                    (\v ->
                        [ Summa.SetValue (Summa.Velocity v)
                        ]
                    )
            , a.tool
                |> Maybe.map
                    (\v ->
                        [ Summa.SetValue (Summa.Tool v)
                        ]
                    )
            , a.cut
                |> Maybe.map
                    (\v ->
                        [ Summa.SetValue
                            (Summa.FlexCut
                                (case v of
                                    ConstCut ->
                                        False

                                    FlexCut ->
                                        True
                                )
                            )
                        ]
                    )
            ]
                |> List.filterMap identity
                |> List.concat
                |> Summa.listToPlotData

        postfix : PlotData
        postfix =
            let
                copies : Int
                copies =
                    a.copies |> Maybe.withDefault 1
            in
            if copies > 1 then
                Summa.Recut
                    |> Summa.toPlotData
                    |> PlotData.toString
                    |> String.repeat (copies - 1)
                    |> PlotData.fromString

            else
                PlotData.fromString ""
    in
    ( prefix, postfix )



--


format : String
format =
    "<Name> [<HorizontalMarkerDistance>x<VerticalMarkerDistance>x<NumberOfMarkers>] [<Speed>mms] [<Copies>x] [pen|knife|pouncer] [const|flex].[dmpl|hpgl]"


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
            [ P.succeed (Just Summa.Pen)
                |. P.symbol "pen"
                |. argEnd
            , P.succeed (Just Summa.Knife)
                |. P.symbol "knife"
                |. argEnd
            , P.succeed (Just Summa.Pouncer)
                |. P.symbol "pouncer"
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

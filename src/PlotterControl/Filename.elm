module PlotterControl.Filename exposing (..)

import Parser as P exposing ((|.), (|=), Parser)
import PlotterControl.Data.Summa as Summa exposing (Summa)


type alias Filename =
    { name : String
    , markers :
        Maybe
            { x : Float
            , y : Float
            , count : Int
            }
    , speed : Maybe Int
    , tool : Maybe Summa.Tool
    , flexCut : Maybe Summa.FlexCut
    , copies : Int
    , format : Format
    }


type Format
    = Dmpl
    | HpGL


fromString : String -> Result (List P.DeadEnd) Filename
fromString a =
    P.run parser a


toSumma : Filename -> ( Summa, Summa )
toSumma a =
    let
        prefix : Summa
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
            , a.flexCut
                |> Maybe.map
                    (\v ->
                        [ Summa.SetValue (Summa.FlexCut v)
                        ]
                    )
            , a.markers
                |> Maybe.map
                    (\_ ->
                        [ Summa.LoadMarkers
                        ]
                    )
            ]
                |> List.filterMap identity
                |> List.concat

        postfix : Summa
        postfix =
            if a.copies > 1 then
                [ Summa.Recut (a.copies - 1)
                ]

            else
                []
    in
    ( prefix, postfix )



--


format : String
format =
    "<Name> [<HorizontalMarkerDistance>x<VerticalMarkerDistance>x<NumberOfVerticalMarkers>] [<Speed>mms] [pen|knife|pouncer] [flexoff|flexfast|flexaccurate] [<Copies>x].<dmpl|hpgl>"


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

        default : Filename
        default =
            { name = "plot"
            , markers = Nothing
            , speed = Nothing
            , tool = Nothing
            , flexCut = Nothing
            , copies = 1
            , format = HpGL
            }

        loop : Filename -> Parser (P.Step Filename Filename)
        loop acc =
            P.oneOf
                [ P.succeed (\x y count -> P.Loop { acc | markers = Just { x = x, y = y, count = count } })
                    |= P.float
                    |. P.symbol "x"
                    |= P.float
                    |. P.symbol "x"
                    |= P.int
                    |. argEnd
                    |> P.backtrackable
                , P.succeed (\v -> P.Loop { acc | speed = Just v })
                    |= P.int
                    |. P.symbol "mms"
                    |. argEnd
                    |> P.backtrackable
                , P.succeed (\_ -> P.Loop { acc | tool = Just Summa.Pen })
                    |= P.symbol "pen"
                    |. argEnd
                    |> P.backtrackable
                , P.succeed (\_ -> P.Loop { acc | tool = Just Summa.Knife })
                    |= P.symbol "knife"
                    |. argEnd
                    |> P.backtrackable
                , P.succeed (\_ -> P.Loop { acc | tool = Just Summa.Pouncer })
                    |= P.symbol "pouncer"
                    |. argEnd
                    |> P.backtrackable
                , P.succeed (\_ -> P.Loop { acc | flexCut = Just Summa.FlexCutOff })
                    |= P.symbol "flexoff"
                    |. argEnd
                    |> P.backtrackable
                , P.succeed (\_ -> P.Loop { acc | flexCut = Just Summa.FlexCutFast })
                    |= P.symbol "flexfast"
                    |. argEnd
                    |> P.backtrackable
                , P.succeed (\_ -> P.Loop { acc | flexCut = Just Summa.FlexCutAccurate })
                    |= P.symbol "flexaccurate"
                    |. argEnd
                    |> P.backtrackable
                , P.succeed (\v -> P.Loop { acc | copies = v })
                    |= P.int
                    |. P.symbol "x"
                    |. argEnd
                    |> P.backtrackable
                , P.succeed (\_ -> P.Done { acc | format = Dmpl })
                    |= P.symbol "dmpl"
                    |. P.end
                , P.succeed (\_ -> P.Done { acc | format = HpGL })
                    |= P.symbol "hpgl"
                    |. P.end
                ]
    in
    P.succeed (\name v -> { v | name = name })
        |= P.getChompedString (chompOneOrMoreIf (\v -> v /= ' ' && v /= '.'))
        |. argEnd
        |= P.loop default loop

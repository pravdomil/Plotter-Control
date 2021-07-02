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
    , copies : Maybe Int
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
            let
                copies : Int
                copies =
                    a.copies |> Maybe.withDefault 1
            in
            if copies > 1 then
                [ Summa.Recut (copies - 1)
                ]

            else
                []
    in
    ( prefix, postfix )



--


format : String
format =
    "<Name> [<HorizontalMarkerDistance>x<VerticalMarkerDistance>x<NumberOfVerticalMarkers>] [<Speed>mms] [pen|knife|pouncer] [noflex|fastflex|accurateflex] [<Copies>x].<dmpl|hpgl>"


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
                |> P.backtrackable
            , P.succeed
                Nothing
            ]
        |= P.oneOf
            [ P.succeed Just
                |= P.int
                |. P.symbol "mms"
                |. argEnd
                |> P.backtrackable
            , P.succeed
                Nothing
            ]
        |= P.oneOf
            [ P.succeed (Just Summa.Pen)
                |. P.symbol "pen"
                |. argEnd
                |> P.backtrackable
            , P.succeed (Just Summa.Knife)
                |. P.symbol "knife"
                |. argEnd
                |> P.backtrackable
            , P.succeed (Just Summa.Pouncer)
                |. P.symbol "pouncer"
                |. argEnd
                |> P.backtrackable
            , P.succeed
                Nothing
            ]
        |= P.oneOf
            [ P.succeed (Just Summa.NoFlexCut)
                |. P.symbol "noflex"
                |. argEnd
                |> P.backtrackable
            , P.succeed (Just Summa.FastFlexCut)
                |. P.symbol "fastflex"
                |. argEnd
                |> P.backtrackable
            , P.succeed (Just Summa.AccurateFlexCut)
                |. P.symbol "accurateflex"
                |. argEnd
                |> P.backtrackable
            , P.succeed
                Nothing
            ]
        |= P.oneOf
            [ P.succeed Just
                |= P.int
                |. P.symbol "x"
                |. argEnd
                |> P.backtrackable
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

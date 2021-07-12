module PlotterControl.Data.HpGl exposing (..)

import Parser as P exposing ((|.), (|=), Parser)


{-| <https://en.wikipedia.org/wiki/HP-GL>
-}
type alias HpGl =
    List Command


type Command
    = Initialize
    | InputScalingPoint (List Point)
    | PenDown (List Point)
    | PenUp (List Point)
    | PageEnd


type alias Point =
    ( Float, Float )


fromString : String -> Result (List P.DeadEnd) HpGl
fromString a =
    P.run parser a


toString : HpGl -> String
toString a =
    a |> List.map commandToString |> String.join ""


commandToString : Command -> String
commandToString a =
    case a of
        Initialize ->
            "IN;"

        InputScalingPoint b ->
            "IP" ++ (b |> List.map pointToString |> String.join ",") ++ ";"

        PenDown b ->
            "PD" ++ (b |> List.map pointToString |> String.join ",") ++ ";"

        PenUp b ->
            "PU" ++ (b |> List.map pointToString |> String.join ",") ++ ";"

        PageEnd ->
            "PG;"


pointToString : Point -> String
pointToString ( a, b ) =
    String.fromFloat a ++ "," ++ String.fromFloat b



--


parser : Parser HpGl
parser =
    let
        loop : HpGl -> Parser (P.Step HpGl HpGl)
        loop acc =
            P.oneOf
                [ P.succeed (\_ -> P.Loop (Initialize :: acc))
                    |= P.symbol "IN"
                    |. P.symbol ";"
                , P.succeed (\v -> P.Loop (InputScalingPoint v :: acc))
                    |. P.symbol "IP"
                    |= pointList
                    |. P.symbol ";"
                , P.succeed (\v -> P.Loop (PenDown v :: acc))
                    |. P.symbol "PD"
                    |= pointList
                    |. P.symbol ";"
                , P.succeed (\v -> P.Loop (PenUp v :: acc))
                    |. P.symbol "PU"
                    |= pointList
                    |. P.symbol ";"
                , P.succeed (\_ -> P.Loop acc)
                    |= P.symbol ";"
                , P.succeed (\_ -> P.Done (List.reverse acc))
                    |= P.end
                ]

        pointList : Parser (List Point)
        pointList =
            P.loop []
                (\acc ->
                    P.oneOf
                        [ P.succeed (\v -> P.Loop (v :: acc))
                            |= pointParser
                        , P.succeed (\_ -> P.Loop acc)
                            |= P.symbol ","
                        , P.succeed (\_ -> P.Done (List.reverse acc))
                            |= P.succeed ()
                        ]
                )
    in
    P.loop [] loop


pointParser : Parser Point
pointParser =
    P.succeed Tuple.pair
        |= P.float
        |. P.symbol ","
        |= P.float

module PlotterControl.Data.Dmpl exposing (..)

import Parser as P exposing ((|.), (|=), Parser)


{-| <https://en.wikipedia.org/wiki/DMPL>
-}
type alias Dmpl =
    List Command


type Command
    = Home
    | ResetOrigin
    | AbsolutePositioning
    | CoordinateResolution
    | PenDown
    | PenUp
    | MoveTo ( Int, Int )


fromString : String -> Result (List P.DeadEnd) Dmpl
fromString a =
    P.run parser a


toString : Dmpl -> String
toString a =
    ";:" ++ (List.map commandToString a |> String.join ",") ++ "@"


commandToString : Command -> String
commandToString a =
    case a of
        Home ->
            "H"

        ResetOrigin ->
            "O"

        AbsolutePositioning ->
            "A"

        CoordinateResolution ->
            "ECN"

        PenDown ->
            "D"

        PenUp ->
            "U"

        MoveTo ( b, c ) ->
            String.fromInt b ++ "," ++ String.fromInt c



--


parser : Parser Dmpl
parser =
    let
        loop : Dmpl -> Parser (P.Step Dmpl Dmpl)
        loop acc =
            P.oneOf
                [ P.succeed (\_ -> P.Loop (Home :: acc))
                    |= P.symbol "H"
                , P.succeed (\_ -> P.Loop (ResetOrigin :: acc))
                    |= P.symbol "O"
                , P.succeed (\_ -> P.Loop (AbsolutePositioning :: acc))
                    |= P.symbol "A"
                , P.succeed (\_ -> P.Loop (CoordinateResolution :: acc))
                    |= P.symbol "ECN"
                , P.succeed (\_ -> P.Loop (PenDown :: acc))
                    |= P.symbol "D"
                , P.succeed (\_ -> P.Loop (PenUp :: acc))
                    |= P.symbol "U"
                , P.succeed (\v1 v2 -> P.Loop (MoveTo ( v1, v2 ) :: acc))
                    |= P.int
                    |. P.symbol ","
                    |= P.int
                , P.succeed (\_ -> P.Loop acc)
                    |= P.symbol ","
                , P.succeed (\() -> P.Done (List.reverse acc))
                    |= P.symbol "@"
                    |. P.end
                ]
    in
    P.succeed identity
        |. P.symbol ";:"
        |= P.loop [] loop

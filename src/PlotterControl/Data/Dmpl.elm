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
    | MoveTo Int Int


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

        MoveTo b c ->
            String.fromInt b ++ "," ++ String.fromInt c

module PlotterControl.Data.HpGl exposing (..)

import Parser as P exposing ((|.), (|=), Parser)


{-| <https://en.wikipedia.org/wiki/HP-GL>
-}
type alias HpGl =
    List Command


type Command
    = Initialize
    | InputScalingPoint (List Float)
    | PenUp (List Float)
    | PenDown (List Float)


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
            "IP" ++ (b |> List.map String.fromFloat |> String.join ",") ++ ";"

        PenUp b ->
            "PU" ++ (b |> List.map String.fromFloat |> String.join ",") ++ ";"

        PenDown b ->
            "PD" ++ (b |> List.map String.fromFloat |> String.join ",") ++ ";"



--


parser : Parser (List Command)
parser =
    let
        loop : List Command -> Parser (P.Step (List Command) (List Command))
        loop acc =
            P.oneOf
                [ P.succeed (P.Loop (Initialize :: acc))
                    |. P.symbol "IN"
                    |. P.symbol ";"
                , P.succeed (\v -> P.Loop (InputScalingPoint v :: acc))
                    |. P.symbol "IP"
                    |= listOfFloats
                    |. P.symbol ";"
                , P.succeed (\v -> P.Loop (PenDown v :: acc))
                    |. P.symbol "PD"
                    |= listOfFloats
                    |. P.symbol ";"
                , P.succeed (\v -> P.Loop (PenUp v :: acc))
                    |. P.symbol "PU"
                    |= listOfFloats
                    |. P.symbol ";"
                , P.succeed (P.Loop acc)
                    |. P.symbol ";"
                , P.succeed (P.Done (List.reverse acc))
                    |. P.end
                ]

        listOfFloats : Parser (List Float)
        listOfFloats =
            P.loop []
                (\acc ->
                    P.oneOf
                        [ P.succeed (\v -> P.Loop (v :: acc))
                            |= P.float
                        , P.succeed (P.Loop acc)
                            |. P.symbol ","
                        , P.succeed (P.Done (List.reverse acc))
                        ]
                )
    in
    P.loop [] loop

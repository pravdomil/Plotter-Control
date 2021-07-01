module PlotterControl.Data.HpGl exposing (..)

import Parser as P exposing ((|.), (|=), Parser)


{-| <https://en.wikipedia.org/wiki/HP-GL>
-}
type alias HpGl =
    List Command


type Command
    = Initialize
    | InputScalingPoint (List Float)
    | PenDown (List Float)
    | PenUp (List Float)


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
            "IP" ++ (b |> List.map String.fromFloat |> String.join ",") ++ ";"

        PenDown b ->
            "PD" ++ (b |> List.map String.fromFloat |> String.join ",") ++ ";"

        PenUp b ->
            "PU" ++ (b |> List.map String.fromFloat |> String.join ",") ++ ";"



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
                , P.succeed (\_ -> P.Loop acc)
                    |= P.symbol ";"
                , P.succeed (\_ -> P.Done (List.reverse acc))
                    |= P.end
                ]

        listOfFloats : Parser (List Float)
        listOfFloats =
            P.loop []
                (\acc ->
                    P.oneOf
                        [ P.succeed (\v -> P.Loop (v :: acc))
                            |= P.float
                        , P.succeed (\_ -> P.Loop acc)
                            |= P.symbol ","
                        , P.succeed (\_ -> P.Done (List.reverse acc))
                            |= P.succeed ()
                        ]
                )
    in
    P.loop [] loop

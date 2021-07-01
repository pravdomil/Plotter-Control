module PlotterControl.Data.HpGl exposing (..)

import Parser as P exposing ((|.), (|=), Parser)
import PlotterControl.Data.PlotData as PlotData exposing (PlotData)


{-| <https://en.wikipedia.org/wiki/HP-GL>
-}
type HpGl
    = HpGl String


type Command
    = Initialize
    | InputScalingPoint (List Float)
    | PenUp (List Float)
    | PenDown (List Float)


fromString : String -> HpGl
fromString =
    HpGl


toString : HpGl -> String
toString (HpGl a) =
    a


toPlotData : HpGl -> PlotData
toPlotData (HpGl a) =
    PlotData.fromString a


append : HpGl -> HpGl -> HpGl
append (HpGl a) (HpGl b) =
    a ++ b |> HpGl



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

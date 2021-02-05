module App.PlotterControl.Filename exposing (..)

import Parser exposing ((|.), (|=), Parser)
import Utils.HpGl exposing (HpGl)
import Utils.SummaCommand as SummaCommand


{-| -}
type alias Filename =
    { name : String

    -- -
    , width : Float

    -- x
    , length : Float

    -- x
    , markers : Int

    -- @
    , speed : Int

    -- x
    , copies : Int

    -- .dat
    }


{-| -}
format : String
format =
    "<name>-<width>x<length>x<markers>@<speed>x<copies>.dat"


{-| -}
fromString : String -> Result String Filename
fromString a =
    case a |> Parser.run parser of
        Ok b ->
            Ok b

        Err _ ->
            Err a


{-| -}
toHpGl : Filename -> HpGl
toHpGl a =
    [ "MARKER_X_SIZE=" ++ String.fromInt (3 * 40)
    , "MARKER_Y_SIZE=" ++ String.fromInt (3 * 40)

    --
    , "MARKER_Y_DIS=" ++ String.fromFloat (a.width * 40)
    , "MARKER_X_DIS=" ++ String.fromFloat (a.length * 40)
    , "MARKER_X_N=" ++ String.fromInt a.markers

    --
    , "VELOCITY=" ++ String.fromInt a.speed
    ]
        |> List.map SummaCommand.Set
        |> SummaCommand.listToHpGl



--


{-| -}
parser : Parser Filename
parser =
    let
        parseInt : String -> Parser Int
        parseInt b =
            case b |> String.toInt of
                Just a ->
                    Parser.succeed a

                Nothing ->
                    Parser.problem "Expecting Int."
    in
    Parser.succeed Filename
        |= Parser.getChompedString (Parser.chompUntil "-")
        |. Parser.symbol "-"
        |= Parser.float
        |. Parser.symbol "x"
        |= Parser.float
        |. Parser.symbol "x"
        |= Parser.int
        |. Parser.symbol "@"
        |= Parser.int
        |. Parser.symbol "x"
        |= (Parser.getChompedString (Parser.chompUntil ".dat") |> Parser.andThen parseInt)
        |. Parser.symbol ".dat"
        |. Parser.end

module App.PlotterControl.Filename exposing (..)

import Parser exposing ((|.), (|=), Parser)
import Utils.HpGl as HpGl exposing (HpGl)
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
toHpGl : Filename -> HpGl -> HpGl
toHpGl f a =
    let
        prefix : HpGl
        prefix =
            [ "MARKER_X_SIZE=" ++ String.fromInt (3 * 40)
            , "MARKER_Y_SIZE=" ++ String.fromInt (3 * 40)

            --
            , "MARKER_Y_DIS=" ++ String.fromFloat (f.width * 40)
            , "MARKER_X_DIS=" ++ String.fromFloat (f.length * 40)
            , "MARKER_X_N=" ++ String.fromInt f.markers

            --
            , "VELOCITY=" ++ String.fromInt f.speed
            ]
                |> List.map SummaCommand.Set
                |> SummaCommand.listToHpGl

        postfix : HpGl
        postfix =
            SummaCommand.Recut |> List.repeat (f.copies - 1) |> SummaCommand.listToHpGl
    in
    HpGl.append (HpGl.append prefix a) postfix



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

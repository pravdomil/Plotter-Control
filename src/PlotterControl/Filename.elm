module PlotterControl.Filename exposing (..)

import Parser exposing ((|.), (|=), Parser)
import PlotterControl.Data.HpGl as HpGl exposing (HpGl)
import PlotterControl.Data.SummaCommand as SummaCommand


type alias Filename =
    { name : String
    , width : Float
    , length : Float
    , markers : Int
    , speed : Int
    , copies : Int
    }


format : String
format =
    "<Name>-<HorizontalMarkerDistance>x<VerticalMarkerDistance>x<NumberOfMarkers>@<Speed>x<Copies>[perf].hpgl"


fromString : String -> Result String Filename
fromString a =
    case a |> Parser.run parser of
        Ok b ->
            Ok b

        Err _ ->
            Err a


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
            SummaCommand.Recut
                |> SummaCommand.toHpGl
                |> HpGl.toString
                |> String.repeat (f.copies - 1)
                |> HpGl.fromString
    in
    HpGl.append (HpGl.append prefix a) postfix



--


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
        |= (Parser.getChompedString (Parser.chompUntil ".hpgl") |> Parser.andThen parseInt)
        |. Parser.symbol ".hpgl"
        |. Parser.end

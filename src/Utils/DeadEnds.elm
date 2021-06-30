module Utils.DeadEnds exposing (..)

import Parser


{-| See <https://github.com/elm/parser/pull/16>.
-}
toString : List Parser.DeadEnd -> String
toString a =
    a |> List.map deadEndToString |> String.join "\n"


deadEndToString : Parser.DeadEnd -> String
deadEndToString a =
    problemToString a.problem ++ " at row " ++ String.fromInt a.row ++ ", col " ++ String.fromInt a.col ++ "."


problemToString : Parser.Problem -> String
problemToString a =
    case a of
        Parser.Expecting b ->
            "Expecting \"" ++ b ++ "\""

        Parser.ExpectingInt ->
            "Expecting int"

        Parser.ExpectingHex ->
            "Expecting hex"

        Parser.ExpectingOctal ->
            "Expecting octal"

        Parser.ExpectingBinary ->
            "Expecting binary"

        Parser.ExpectingFloat ->
            "Expecting float"

        Parser.ExpectingNumber ->
            "Expecting number"

        Parser.ExpectingVariable ->
            "Expecting variable"

        Parser.ExpectingSymbol b ->
            "Expecting symbol \"" ++ b ++ "\""

        Parser.ExpectingKeyword b ->
            "Expecting keyword \"" ++ b ++ "\""

        Parser.ExpectingEnd ->
            "Expecting end"

        Parser.UnexpectedChar ->
            "Unexpected character"

        Parser.Problem b ->
            "Problem " ++ b

        Parser.BadRepeat ->
            "Bad repeat"

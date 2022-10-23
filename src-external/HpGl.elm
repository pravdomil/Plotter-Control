module HpGl exposing (..)

import BoundingBox2d
import Length
import Parser exposing ((|.), (|=))
import Point2d
import Quantity


{-| Hewlett-Packard Graphics Language
<https://en.wikipedia.org/wiki/HP-GL>
-}
type alias HpGl =
    List Command


fromString : String -> Result (List Parser.DeadEnd) HpGl
fromString a =
    a |> Parser.run parser


toString : HpGl -> String
toString a =
    a |> List.map commandToString |> String.join ""


resolution : Quantity.Quantity Float (Quantity.Rate Quantity.Unitless Length.Meters)
resolution =
    Quantity.rate (Quantity.float 1) (Length.millimeters 0.025)



--


type Command
    = Initialize
    | Begin
    | End
      --
    | MoveAbsolute Points
    | MoveRelative Points
    | ToolDown Points
    | ToolUp Points
      --
    | CutOff
    | InputViewport BoundingBox
    | Pressure Int
    | Report
    | Tool Int
    | Velocity Int


commandToString : Command -> String
commandToString a =
    case a of
        Initialize ->
            "IN;"

        Begin ->
            "BP;"

        End ->
            "PG;"

        --
        MoveAbsolute b ->
            "PA" ++ pointsToString b ++ ";"

        MoveRelative b ->
            "PR" ++ pointsToString b ++ ";"

        ToolDown b ->
            "PD" ++ pointsToString b ++ ";"

        ToolUp b ->
            "PU" ++ pointsToString b ++ ";"

        --
        CutOff ->
            "EC;"

        InputViewport b ->
            "IP" ++ boundingBoxToString b ++ ";"

        Pressure b ->
            "FS" ++ String.fromInt b ++ ";"

        Report ->
            "OH;"

        Tool b ->
            "SP" ++ String.fromInt b ++ ";"

        Velocity b ->
            "VS" ++ String.fromInt b ++ ";"



--


type alias BoundingBox =
    BoundingBox2d.BoundingBox2d Length.Meters ()


boundingBoxToString : BoundingBox -> String
boundingBoxToString a =
    let
        b =
            a |> BoundingBox2d.extrema
    in
    (Point2d.xy b.minX b.minY |> pointToString)
        ++ ","
        ++ (Point2d.xy b.maxX b.maxY |> pointToString)



--


type alias Points =
    List Point


pointsToString : Points -> String
pointsToString a =
    a |> List.map pointToString |> String.join ","



--


type alias Point =
    Point2d.Point2d Length.Meters ()


pointToString : Point -> String
pointToString a =
    (a |> Point2d.xCoordinate |> lengthToString)
        ++ ","
        ++ (a |> Point2d.yCoordinate |> lengthToString)



--


lengthToString : Length.Length -> String
lengthToString a =
    a
        |> Quantity.at resolution
        |> Quantity.toFloat
        |> round
        |> String.fromInt



--


parser : Parser.Parser HpGl
parser =
    let
        loop : HpGl -> Parser.Parser (Parser.Step HpGl HpGl)
        loop acc =
            Parser.oneOf
                [ commandParser
                    |> Parser.map (\x -> Parser.Loop (x :: acc))
                , Parser.chompIf (\x -> x == ' ' || x == '\n' || x == '\u{000D}' || x == ';')
                    |> Parser.map (\_ -> Parser.Loop acc)
                , Parser.end
                    |> Parser.map (\_ -> Parser.Done (List.reverse acc))
                ]
    in
    Parser.loop [] loop


commandParser : Parser.Parser Command
commandParser =
    let
        pointsParser : Parser.Parser Points
        pointsParser =
            Parser.loop []
                (\acc ->
                    Parser.oneOf
                        [ pointParser
                            |> Parser.map (\x -> Parser.Loop (x :: acc))
                        , Parser.symbol ","
                            |> Parser.map (\_ -> Parser.Loop acc)
                        , Parser.succeed ()
                            |> Parser.map (\_ -> Parser.Done (List.reverse acc))
                        ]
                )

        pointParser : Parser.Parser Point
        pointParser =
            Parser.succeed Point2d.xy
                |= (Parser.float |> Parser.map (Quantity.float >> Quantity.at_ resolution))
                |. Parser.symbol ","
                |= (Parser.float |> Parser.map (Quantity.float >> Quantity.at_ resolution))

        boundingBoxParser : Parser.Parser BoundingBox
        boundingBoxParser =
            Parser.succeed BoundingBox2d.from
                |= pointParser
                |. Parser.symbol ","
                |= pointParser

        simpleCommands : List Command
        simpleCommands =
            [ Initialize, Begin, End, CutOff, Report ]
    in
    Parser.oneOf
        [ Parser.oneOf
            (simpleCommands
                |> List.map
                    (\x ->
                        Parser.symbol (commandToString x)
                            |> Parser.map (\_ -> x)
                    )
            )
        , Parser.symbol "PA"
            |> Parser.andThen
                (\_ -> pointsParser |> Parser.map MoveAbsolute)
        , Parser.symbol "PR"
            |> Parser.andThen
                (\_ -> pointsParser |> Parser.map MoveRelative)
        , Parser.symbol "PD"
            |> Parser.andThen
                (\_ -> pointsParser |> Parser.map ToolDown)
        , Parser.symbol "PU"
            |> Parser.andThen
                (\_ -> pointsParser |> Parser.map ToolUp)
        , Parser.symbol "IP"
            |> Parser.andThen
                (\_ -> boundingBoxParser |> Parser.map InputViewport)
        , Parser.symbol "FS"
            |> Parser.andThen
                (\_ -> Parser.int |> Parser.map Pressure)
        , Parser.symbol "SP"
            |> Parser.andThen
                (\_ -> Parser.int |> Parser.map Tool)
        , Parser.symbol "VS"
            |> Parser.andThen
                (\_ -> Parser.int |> Parser.map Velocity)
        ]

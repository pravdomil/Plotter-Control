module PlotterControl.Data.HP_GL exposing (..)

import BoundingBox2d
import Parser exposing ((|.), (|=))
import Point2d
import Quantity


{-| Hewlett-Packard Graphics Language
<https://en.wikipedia.org/wiki/HP-GL>
-}
type alias HP_GL =
    List Command


fromString : String -> Result (List Parser.DeadEnd) HP_GL
fromString a =
    a |> Parser.run parser


toString : HP_GL -> String
toString a =
    a |> List.map commandToString |> String.join ""



--


type Command
    = Initialize
    | Begin
      --
    | MoveAbsolute Point
    | MoveRelative Point
    | ToolDown Point
    | ToolUp Point
      --
    | CutOff
    | End
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

        --
        MoveAbsolute b ->
            "PA" ++ pointToString b ++ ";"

        MoveRelative b ->
            "PR" ++ pointToString b ++ ";"

        ToolDown b ->
            "PD" ++ pointToString b ++ ";"

        ToolUp b ->
            "PU" ++ pointToString b ++ ";"

        --
        CutOff ->
            "EC;"

        End ->
            "PG;"

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
    BoundingBox2d.BoundingBox2d Quantity.Unitless ()


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


type alias Point =
    Point2d.Point2d Quantity.Unitless ()


pointToString : Point -> String
pointToString a =
    (a |> Point2d.xCoordinate |> Quantity.toFloat |> String.fromFloat)
        ++ ","
        ++ (a |> Point2d.yCoordinate |> Quantity.toFloat |> String.fromFloat)



--


parser : Parser.Parser HP_GL
parser =
    let
        loop : HP_GL -> Parser.Parser (Parser.Step HP_GL HP_GL)
        loop acc =
            Parser.oneOf
                [ commandParser
                    |> Parser.map (\v -> Parser.Loop (v :: acc))
                , Parser.chompIf (\v -> v == ' ' || v == '\n' || v == '\u{000D}' || v == ';')
                    |> Parser.map (\_ -> Parser.Loop acc)
                , Parser.end
                    |> Parser.map (\_ -> Parser.Done (List.reverse acc))
                ]
    in
    Parser.loop [] loop


commandParser : Parser.Parser Command
commandParser =
    let
        pointParser : Parser.Parser Point
        pointParser =
            Parser.succeed Point2d.xy
                |= (Parser.float |> Parser.map Quantity.float)
                |. Parser.symbol ","
                |= (Parser.float |> Parser.map Quantity.float)

        boundingBoxParser : Parser.Parser BoundingBox
        boundingBoxParser =
            Parser.succeed BoundingBox2d.from
                |= pointParser
                |. Parser.symbol ","
                |= pointParser

        simpleCommands : List Command
        simpleCommands =
            [ Initialize, Begin, CutOff, End, Report ]
    in
    Parser.oneOf
        [ Parser.oneOf
            (simpleCommands
                |> List.map
                    (\v ->
                        Parser.symbol (commandToString v)
                            |> Parser.map (\_ -> v)
                    )
            )
        , Parser.symbol "PA"
            |> Parser.andThen
                (\_ -> pointParser |> Parser.map MoveAbsolute)
        , Parser.symbol "PR"
            |> Parser.andThen
                (\_ -> pointParser |> Parser.map MoveRelative)
        , Parser.symbol "PD"
            |> Parser.andThen
                (\_ -> pointParser |> Parser.map ToolDown)
        , Parser.symbol "PU"
            |> Parser.andThen
                (\_ -> pointParser |> Parser.map ToolUp)
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

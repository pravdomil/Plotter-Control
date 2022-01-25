module DMPL exposing (..)

import BoundingBox2d
import Parser exposing ((|.), (|=))
import Point2d
import Quantity


{-| Digital Microprocessor Plotter Language
<https://en.wikipedia.org/wiki/DMPL>
-}
type alias DMPL =
    List Command


fromString : String -> Result (List Parser.DeadEnd) DMPL
fromString a =
    a |> Parser.run parser


toString : DMPL -> String
toString a =
    a |> List.map commandToString |> String.join " "



--


type Command
    = SelectCutter
    | DeselectCutter
    | ResetCutter
    | End
      --
    | SetResolution Resolution
    | SetWindow Window
      --
    | AbsoluteCoordinates
    | RelativeCoordinates
      --
    | ToolDown
    | ToolUp
    | MoveTo Point
      --
    | Tool Int
    | CutOff
    | MoveOrigin Int
    | PlotLength Int
    | Pressure Int
    | Report
    | Velocity Int


commandToString : Command -> String
commandToString a =
    case a of
        SelectCutter ->
            ";:"

        DeselectCutter ->
            "@"

        ResetCutter ->
            "Z"

        End ->
            "e"

        --
        SetResolution b ->
            resolutionToString b

        SetWindow b ->
            "W" ++ windowToString b

        --
        AbsoluteCoordinates ->
            "A"

        RelativeCoordinates ->
            "R"

        --
        ToolDown ->
            "D"

        ToolUp ->
            "U"

        MoveTo b ->
            pointToString b

        --
        Tool b ->
            "P" ++ String.fromInt b

        CutOff ->
            "c"

        MoveOrigin b ->
            "F" ++ String.fromInt b

        PlotLength b ->
            "EW" ++ String.fromInt b

        Pressure b ->
            "BP" ++ String.fromInt b

        Report ->
            "ER"

        Velocity b ->
            "V" ++ String.fromInt b



--


type Resolution
    = Thou1
    | Thou5
    | Microns25
    | Microns100


allResolutions : List Resolution
allResolutions =
    [ Thou1, Thou5, Microns25, Microns100 ]


resolutionToString : Resolution -> String
resolutionToString a =
    case a of
        Thou1 ->
            "EC1"

        Thou5 ->
            "EC5"

        Microns25 ->
            "ECN"

        Microns100 ->
            "ECM"



--


type alias Window =
    { window : BoundingBox
    , viewport : BoundingBox
    }


windowToString : Window -> String
windowToString a =
    (a.window |> boundingBoxToString)
        ++ " "
        ++ (a.viewport |> boundingBoxToString)



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
        ++ " "
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


parser : Parser.Parser DMPL
parser =
    let
        loop : DMPL -> Parser.Parser (Parser.Step DMPL DMPL)
        loop acc =
            Parser.oneOf
                [ commandParser
                    |> Parser.map (\v -> Parser.Loop (v :: acc))
                , Parser.chompIf (\v -> v == ' ' || v == '\n' || v == '\u{000D}')
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
                |= (Parser.int |> Parser.map (Quantity.int >> Quantity.toFloatQuantity))
                |. Parser.symbol ","
                |= (Parser.int |> Parser.map (Quantity.int >> Quantity.toFloatQuantity))

        boundingBoxParser : Parser.Parser BoundingBox
        boundingBoxParser =
            Parser.succeed BoundingBox2d.from
                |= pointParser
                |. Parser.symbol " "
                |= pointParser

        windowParser : Parser.Parser Window
        windowParser =
            Parser.succeed Window
                |= boundingBoxParser
                |. Parser.symbol " "
                |= boundingBoxParser

        simpleCommands : List Command
        simpleCommands =
            [ SelectCutter
            , DeselectCutter
            , ResetCutter
            , End
            , AbsoluteCoordinates
            , RelativeCoordinates
            , ToolDown
            , ToolUp
            , CutOff
            , Report
            ]
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
        , Parser.oneOf
            (allResolutions
                |> List.map
                    (\v ->
                        Parser.symbol (resolutionToString v)
                            |> Parser.map (\_ -> SetResolution v)
                    )
            )
        , Parser.symbol "W"
            |> Parser.andThen (\_ -> windowParser |> Parser.map SetWindow)
        , Parser.symbol "P"
            |> Parser.andThen (\_ -> Parser.int |> Parser.map Tool)
        , Parser.symbol "F"
            |> Parser.andThen (\_ -> Parser.int |> Parser.map MoveOrigin)
        , Parser.symbol "EW"
            |> Parser.andThen (\_ -> Parser.int |> Parser.map PlotLength)
        , Parser.symbol "BP"
            |> Parser.andThen (\_ -> Parser.int |> Parser.map Pressure)
        , Parser.symbol "V"
            |> Parser.andThen (\_ -> Parser.int |> Parser.map Velocity)
        , pointParser
            |> Parser.map MoveTo
        ]

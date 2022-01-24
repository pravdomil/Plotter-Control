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
    | ChangeTool Int
    | CutOff
    | End
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
        ChangeTool b ->
            "P" ++ String.fromInt b

        CutOff ->
            "c"

        End ->
            "e"

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



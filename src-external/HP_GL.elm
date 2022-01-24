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

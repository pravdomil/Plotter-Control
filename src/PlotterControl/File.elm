module PlotterControl.File exposing (..)

import Angle
import Axis2d
import BoundingBox2d
import Dict
import File
import HpGl
import HpGl.Geometry
import Length
import Parser
import Pixels
import PlotterControl.Markers
import PlotterControl.Settings
import Point2d
import Polyline2d
import Quantity
import Rectangle2d
import SummaEl
import Task
import Time
import Vector2d
import XmlParser


type alias File =
    { ready : Result Error Ready

    --
    , created : Time.Posix
    }


fromFile : File.File -> Task.Task x ( Name, File )
fromFile a =
    let
        name : String
        name =
            File.name a

        name_ : Name
        name_ =
            stringToName
                (if name |> String.endsWith supportedExtension then
                    name |> String.dropRight (String.length supportedExtension)

                 else
                    name
                )
    in
    Task.map2
        (\x x2 ->
            ( name_
            , File x x2
            )
        )
        (if a |> File.name |> String.endsWith supportedExtension then
            hpGlFileToReady a

         else
            Task.succeed (Err FileNotSupported)
        )
        Time.now


supportedExtension : String
supportedExtension =
    ".hpgl"



--


type Name
    = Name String


stringToName : String -> Name
stringToName =
    Name


nameToString : Name -> String
nameToString (Name a) =
    a



--


type alias Ready =
    { polylines : List (Polyline2d.Polyline2d Length.Meters ())
    , markers : Maybe PlotterControl.Markers.Markers
    , settings : PlotterControl.Settings.Settings
    }


hpGlFileToReady : File.File -> Task.Task x (Result Error Ready)
hpGlFileToReady a =
    a
        |> File.toString
        |> Task.map
            (\x ->
                x
                    |> HpGl.fromString
                    |> Result.mapError ParserError
                    |> Result.map HpGl.Geometry.polylines
                    |> Result.andThen (PlotterControl.Markers.fromPolylines >> Result.mapError MarkersError)
                    |> Result.map
                        (\( polylines, markers ) ->
                            Ready
                                polylines
                                markers
                                (PlotterControl.Settings.default (File.name a))
                        )
            )


readySettingsToSummaEl : Ready -> SummaEl.SummaEl
readySettingsToSummaEl a =
    PlotterControl.Settings.loadSettings
        (a.markers
            |> Maybe.map PlotterControl.Markers.toSettings
            |> Maybe.withDefault Dict.empty
        )
        a.settings


readyToPlotterData : Ready -> String
readyToPlotterData a =
    let
        usePerforationRelief : Bool
        usePerforationRelief =
            (a.settings.preset == PlotterControl.Settings.Perforate)
                && (PlotterControl.Settings.copiesToInt a.settings.copies > 1)
    in
    let
        setSettings : String
        setSettings =
            SummaEl.toString
                (readySettingsToSummaEl a
                    |> (\x ->
                            if usePerforationRelief then
                                x
                                    ++ [ SummaEl.SetSettings (Dict.singleton "RECUT_OFFSET" "0")
                                       ]

                            else
                                x
                       )
                )

        maybeLoadMarkers : String
        maybeLoadMarkers =
            case a.markers of
                Just _ ->
                    SummaEl.toString
                        [ SummaEl.LoadMarkers
                        ]

                Nothing ->
                    ""

        movePolylines : List (Polyline2d.Polyline2d Length.Meters coordinates) -> List (Polyline2d.Polyline2d Length.Meters coordinates)
        movePolylines b =
            b
                |> List.map
                    (Polyline2d.mapVertices
                        (Point2d.translateBy
                            (Vector2d.xy
                                (Quantity.float 1 |> Quantity.at_ HpGl.resolution)
                                Quantity.zero
                            )
                        )
                    )

        data : String
        data =
            HpGl.toString
                (HpGl.Initialize
                    :: HpGl.Geometry.fromPolylines
                        (if a.settings.preset == PlotterControl.Settings.Perforate then
                            movePolylines a.polylines

                         else
                            a.polylines
                        )
                    ++ (if usePerforationRelief then
                            HpGl.Geometry.fromPolylines (perforationRelief a)

                        else
                            []
                       )
                    ++ [ HpGl.End ]
                )

        maybeRecut : String
        maybeRecut =
            a.settings.copies
                |> PlotterControl.Settings.copiesToInt
                |> (\x ->
                        if x > 1 then
                            SummaEl.toString
                                [ SummaEl.Recut (x - 1)
                                ]

                        else
                            ""
                   )
    in
    setSettings ++ maybeLoadMarkers ++ data ++ maybeRecut


perforationRelief : Ready -> List (Polyline2d.Polyline2d Length.Meters coordinates)
perforationRelief a =
    let
        polylinesBox : Maybe (BoundingBox2d.BoundingBox2d Length.Meters ())
        polylinesBox =
            a.polylines
                |> List.filterMap Polyline2d.boundingBox
                |> BoundingBox2d.aggregateN

        nextCopy : Maybe (Point2d.Point2d Length.Meters coordinates)
        nextCopy =
            polylinesBox
                |> Maybe.map
                    (\box ->
                        Point2d.xy
                            ((case a.markers of
                                Just x2 ->
                                    BoundingBox2d.aggregate box [ PlotterControl.Markers.boundingBox x2 ]

                                Nothing ->
                                    box
                             )
                                |> BoundingBox2d.maxX
                                |> Quantity.plus a.settings.copyDistance
                            )
                            Quantity.zero
                    )
    in
    Maybe.map2
        (\box x ->
            [ Polyline2d.fromVertices
                [ Point2d.xy (Point2d.xCoordinate x) (BoundingBox2d.maxY box)
                , Point2d.xy (BoundingBox2d.maxX box) (BoundingBox2d.maxY box)
                ]
            , Polyline2d.fromVertices
                [ Point2d.xy (Point2d.xCoordinate x) (BoundingBox2d.minY box)
                , Point2d.xy (BoundingBox2d.maxX box) (BoundingBox2d.minY box)
                ]
            ]
        )
        polylinesBox
        nextCopy
        |> Maybe.withDefault []


readyToSvg : Ready -> String
readyToSvg a =
    let
        lengthToString : Length.Length -> String
        lengthToString b =
            String.fromFloat (Pixels.inPixels (Quantity.at resolution b))

        pointToString : Point2d.Point2d Length.Meters coordinates -> String
        pointToString b =
            lengthToString (Point2d.xCoordinate b)
                ++ ","
                ++ lengthToString (Point2d.yCoordinate b)

        polylineToSvg : Polyline2d.Polyline2d Length.Meters coordinates -> XmlParser.Node
        polylineToSvg b =
            XmlParser.Element "polyline"
                [ XmlParser.Attribute "points" (b |> Polyline2d.vertices |> List.map pointToString |> String.join " ")
                , XmlParser.Attribute "stroke" "#000000"
                , XmlParser.Attribute "fill" "none"
                ]
                []

        rectangleToSvg : Rectangle2d.Rectangle2d Length.Meters coordinates -> XmlParser.Node
        rectangleToSvg b =
            let
                ( w, h ) =
                    Rectangle2d.dimensions b

                center : Point2d.Point2d Length.Meters coordinates
                center =
                    Rectangle2d.centerPoint b
            in
            XmlParser.Element "rect"
                [ XmlParser.Attribute "x" (center |> Point2d.xCoordinate |> Quantity.minus (w |> Quantity.half) |> lengthToString)
                , XmlParser.Attribute "y" (center |> Point2d.yCoordinate |> Quantity.minus (h |> Quantity.half) |> lengthToString)
                , XmlParser.Attribute "width" (lengthToString w)
                , XmlParser.Attribute "height" (lengthToString h)
                ]
                []

        boundingBoxToViewBox : BoundingBox2d.BoundingBox2d Length.Meters coordinates -> String
        boundingBoxToViewBox b =
            let
                ( width, height ) =
                    BoundingBox2d.dimensions b
            in
            lengthToString (BoundingBox2d.minX b)
                ++ " "
                ++ lengthToString (BoundingBox2d.minY b)
                ++ " "
                ++ lengthToString width
                ++ " "
                ++ lengthToString height

        resolution : Quantity.Quantity Float (Quantity.Rate Pixels.Pixels Length.Meters)
        resolution =
            Pixels.pixels 72 |> Quantity.per (Length.inches 1)

        box : BoundingBox2d.BoundingBox2d Length.Meters ()
        box =
            polylines
                |> List.filterMap Polyline2d.boundingBox
                |> BoundingBox2d.aggregateN
                |> Maybe.map
                    (\x ->
                        BoundingBox2d.aggregate x (markers |> List.map Rectangle2d.boundingBox)
                    )
                |> Maybe.withDefault (BoundingBox2d.from Point2d.origin Point2d.origin)

        rotation : Angle.Angle
        rotation =
            Angle.degrees -90

        polylines : List (Polyline2d.Polyline2d Length.Meters ())
        polylines =
            a.polylines
                |> List.map (Polyline2d.mirrorAcross Axis2d.x >> Polyline2d.rotateAround Point2d.origin rotation)

        markers : List (Rectangle2d.Rectangle2d Length.Meters coordinates)
        markers =
            a.markers
                |> Maybe.map PlotterControl.Markers.rectangles
                |> Maybe.withDefault []
                |> List.map (Rectangle2d.mirrorAcross Axis2d.x >> Rectangle2d.rotateAround Point2d.origin rotation)

        toZero : Vector2d.Vector2d Length.Meters coordinates
        toZero =
            Vector2d.from
                (Point2d.xy (BoundingBox2d.minX box) (BoundingBox2d.minY box))
                Point2d.origin

        node : XmlParser.Node
        node =
            XmlParser.Element "svg"
                [ XmlParser.Attribute "xmlns" "http://www.w3.org/2000/svg"
                , XmlParser.Attribute "viewBox" (box |> BoundingBox2d.translateBy toZero |> boundingBoxToViewBox)
                ]
                ((polylines |> List.map (Polyline2d.translateBy toZero >> polylineToSvg))
                    ++ (markers |> List.map (Rectangle2d.translateBy toZero >> rectangleToSvg))
                )
    in
    XmlParser.format (XmlParser.Xml [] Nothing node)



--


type Error
    = FileNotSupported
    | ParserError (List Parser.DeadEnd)
    | MarkersError PlotterControl.Markers.Error

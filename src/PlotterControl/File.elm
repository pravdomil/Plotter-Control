module PlotterControl.File exposing (..)

import BoundingBox2d
import Dict
import File
import HpGl
import HpGl.Geometry
import Length
import Parser
import PlotterControl.Markers
import PlotterControl.Settings
import Point2d
import Polyline2d
import Quantity
import SummaEl
import Task
import Time
import Vector2d


type alias File =
    { ready : Result Error Ready

    --
    , created : Time.Posix
    }


fromFile : File.File -> Task.Task x ( Name, File )
fromFile a =
    Task.map2
        (\x x2 ->
            ( stringToName (String.dropRight (String.length supportedExtension) (File.name a))
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
                (if usePerforationRelief then
                    readySettingsToSummaEl a
                        ++ [ SummaEl.SetSettings (Dict.singleton "RECUT_OFFSET" "0")
                           ]

                 else
                    readySettingsToSummaEl a
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

        data : String
        data =
            if usePerforationRelief then
                HpGl.toString
                    (HpGl.Initialize
                        :: HpGl.Geometry.fromPolylines (polylinesPreventDoubleCut a.markers a.polylines)
                        ++ HpGl.Geometry.fromPolylines (perforationRelief a)
                        ++ [ HpGl.End ]
                    )

            else
                HpGl.toString
                    (HpGl.Initialize
                        :: HpGl.Geometry.fromPolylines a.polylines
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


polylinesPreventDoubleCut : Maybe PlotterControl.Markers.Markers -> List (Polyline2d.Polyline2d Length.Meters coordinates) -> List (Polyline2d.Polyline2d Length.Meters coordinates)
polylinesPreventDoubleCut markers a =
    let
        tolerance : Length.Length
        tolerance =
            Length.millimeters 0.2
    in
    case markers of
        Just markers_ ->
            let
                maxX : Quantity.Quantity Float Length.Meters
                maxX =
                    markers_
                        |> PlotterControl.Markers.boundingBox
                        |> BoundingBox2d.maxX
                        |> Quantity.minus tolerance
            in
            a
                |> List.map
                    (\x ->
                        case Polyline2d.boundingBox x of
                            Just box ->
                                if BoundingBox2d.maxX box |> Quantity.greaterThan maxX then
                                    Polyline2d.translateBy (Vector2d.xy (Quantity.negate tolerance) Quantity.zero) x

                                else
                                    x

                            Nothing ->
                                x
                    )

        Nothing ->
            a


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



--


type Error
    = FileNotSupported
    | ParserError (List Parser.DeadEnd)
    | MarkersError PlotterControl.Markers.Error

module PlotterControl.File exposing (..)

import BoundingBox2d
import Dict
import File
import HpGl
import HpGl.Geometry
import Length
import Parser
import PlotterControl.Settings
import Polyline2d
import Quantity
import SummaEl
import Task
import Time


type alias File =
    { ready : Result Error Ready

    --
    , created : Time.Posix
    }


fromFile : File.File -> Task.Task x ( Name, File )
fromFile a =
    Task.map2
        (\x x2 ->
            ( stringToName (File.name a)
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
    , markers : Maybe Markers
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
                    |> Result.andThen filterMarkers
                    |> Result.map
                        (\( polylines, markers ) ->
                            Ready
                                polylines
                                markers
                                (PlotterControl.Settings.default (File.name a))
                        )
            )


readyToSettings : Ready -> SummaEl.Settings
readyToSettings a =
    Dict.union
        (a.markers |> Maybe.map markersToSettings |> Maybe.withDefault Dict.empty)
        (a.settings |> PlotterControl.Settings.toSettings)


readyToPlotterData : Ready -> String
readyToPlotterData a =
    let
        setSettings : String
        setSettings =
            SummaEl.toString
                [ SummaEl.SetSettings (readyToSettings a)
                ]

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
            a.polylines
                |> HpGl.Geometry.fromPolylines
                |> (\x -> [ HpGl.Initialize ] ++ x ++ [ HpGl.End ])
                |> HpGl.toString

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
    String.join "\n"
        [ setSettings
        , maybeLoadMarkers
        , data
        , maybeRecut
        ]



--


type alias Markers =
    { xDistance : Length.Length
    , yDistance : Length.Length
    , count : Int
    }


markersToSettings : Markers -> SummaEl.Settings
markersToSettings a =
    Dict.fromList
        [ ( "MARKER_X_DIS", a.xDistance |> HpGl.lengthToString )
        , ( "MARKER_Y_DIS", a.yDistance |> HpGl.lengthToString )
        , ( "MARKER_X_SIZE", markerSize |> HpGl.lengthToString )
        , ( "MARKER_Y_SIZE", markerSize |> HpGl.lengthToString )
        , ( "MARKER_X_N", a.count |> String.fromInt )
        ]


filterMarkers :
    List (Polyline2d.Polyline2d Length.Meters ())
    -> Result Error ( List (Polyline2d.Polyline2d Length.Meters ()), Maybe Markers )
filterMarkers a =
    let
        isFirstMark : Polyline2d.Polyline2d Length.Meters coordinates -> Bool
        isFirstMark b =
            b
                |> Polyline2d.boundingBox
                |> Maybe.map
                    (\x ->
                        boxHasSameSizeAsMarker x
                            && (x |> BoundingBox2d.minX |> Quantity.equalWithin (Length.millimeters 0.11) Quantity.zero)
                            && (x |> BoundingBox2d.minY |> Quantity.equalWithin (Length.millimeters 0.11) Quantity.zero)
                    )
                |> Maybe.withDefault False
    in
    if a |> List.any isFirstMark then
        filterMarkersHelper a

    else
        Ok
            ( a
            , Nothing
            )


filterMarkersHelper :
    List (Polyline2d.Polyline2d Length.Meters coordinates)
    -> Result Error ( List (Polyline2d.Polyline2d Length.Meters coordinates), Maybe { xDistance : Quantity.Quantity Float Length.Meters, yDistance : Quantity.Quantity Float Length.Meters, count : Int } )
filterMarkersHelper a =
    let
        box : BoundingBox2d.BoundingBox2d Length.Meters coordinates
        box =
            a
                |> List.concatMap Polyline2d.vertices
                |> BoundingBox2d.hullN
                |> Maybe.withDefault
                    (BoundingBox2d.fromExtrema
                        { minX = Quantity.zero
                        , maxX = Quantity.zero
                        , minY = Quantity.zero
                        , maxY = Quantity.zero
                        }
                    )

        isMark : Polyline2d.Polyline2d Length.Meters coordinates -> Bool
        isMark b =
            b
                |> Polyline2d.boundingBox
                |> Maybe.map
                    (\x ->
                        boxHasSameSizeAsMarker x
                            && ((x |> BoundingBox2d.minY |> Quantity.equalWithin tolerance (box |> BoundingBox2d.minY))
                                    || (x |> BoundingBox2d.maxY |> Quantity.equalWithin tolerance (box |> BoundingBox2d.maxY))
                               )
                    )
                |> Maybe.withDefault False

        ( markers, lines ) =
            a |> List.partition isMark

        markersCount : Int
        markersCount =
            markers |> List.length
    in
    if markersCount < 4 || modBy 2 markersCount == 1 then
        Err InvalidMarkerCount

    else
        let
            ( w, h ) =
                markers
                    |> List.concatMap Polyline2d.vertices
                    |> BoundingBox2d.hullN
                    |> Maybe.withDefault
                        (BoundingBox2d.fromExtrema
                            { minX = Quantity.zero
                            , maxX = Quantity.zero
                            , minY = Quantity.zero
                            , maxY = Quantity.zero
                            }
                        )
                    |> BoundingBox2d.dimensions

            markers_ : Markers
            markers_ =
                { xDistance = w |> Quantity.minus markerSize |> Quantity.divideBy (toFloat (markersCount // 2 - 1))
                , yDistance = h |> Quantity.minus markerSize
                , count = markersCount // 2
                }
        in
        Ok
            ( lines
            , Just markers_
            )


markerSize : Length.Length
markerSize =
    Length.millimeters 3


tolerance : Length.Length
tolerance =
    Quantity.float 1 |> Quantity.at_ HpGl.resolution


boxHasSameSizeAsMarker : BoundingBox2d.BoundingBox2d Length.Meters coordinates -> Bool
boxHasSameSizeAsMarker b =
    b
        |> BoundingBox2d.dimensions
        |> (\( w, h ) ->
                (w |> Quantity.equalWithin tolerance markerSize)
                    && (h |> Quantity.equalWithin tolerance markerSize)
           )



--


type Error
    = FileNotSupported
    | InvalidMarkerCount
    | ParserError (List Parser.DeadEnd)

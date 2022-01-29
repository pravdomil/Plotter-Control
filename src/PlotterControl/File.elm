module PlotterControl.File exposing (..)

import BoundingBox2d
import Dict
import File
import HP_GL
import HP_GL.Geometry
import Length
import Parser
import Polyline2d
import Quantity
import SummaEL


type alias File =
    { name : Name
    , polylines : List (Polyline2d.Polyline2d Length.Meters ())
    , markers : Maybe Markers
    }


fromFile : File.File -> String -> Result Error File
fromFile a b =
    if a |> File.name |> String.endsWith ".hpgl" then
        fromHP_GLFile a b

    else
        Err FileNotSupported


fromHP_GLFile : File.File -> String -> Result Error File
fromHP_GLFile a b =
    b
        |> HP_GL.fromString
        |> Result.mapError ParserError
        |> Result.map HP_GL.Geometry.polylines
        |> Result.andThen filterMarkers
        |> Result.map
            (\( polylines, markers ) ->
                { name = a |> File.name |> Name
                , polylines = polylines
                , markers = markers
                }
            )


toCommands : File -> ( SummaEL.SummaEL, HP_GL.HP_GL )
toCommands a =
    ( case a.markers of
        Just b ->
            [ SummaEL.SetSettings
                (Dict.fromList
                    [ ( "MARKER_X_DIS", b.xDistance |> HP_GL.lengthToString )
                    , ( "MARKER_Y_DIS", b.yDistance |> HP_GL.lengthToString )
                    , ( "MARKER_X_SIZE", markerSize |> HP_GL.lengthToString )
                    , ( "MARKER_Y_SIZE", markerSize |> HP_GL.lengthToString )
                    , ( "MARKER_X_N", b.count |> String.fromInt )
                    ]
                )
            , SummaEL.LoadMarkers
            ]

        Nothing ->
            []
    , a.polylines
        |> HP_GL.Geometry.fromPolylines
        |> (\v -> [ HP_GL.Initialize ] ++ v ++ [ HP_GL.End ])
    )



--


type Name
    = Name String



--


type alias Markers =
    { xDistance : Length.Length
    , yDistance : Length.Length
    , count : Int
    }


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
                    (\v ->
                        boxHasSameSizeAsMarker v
                            && (v |> BoundingBox2d.minX |> Quantity.equalWithin (Length.millimeters 0.11) Quantity.zero)
                            && (v |> BoundingBox2d.minY |> Quantity.equalWithin (Length.millimeters 0.11) Quantity.zero)
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
                    (\v ->
                        boxHasSameSizeAsMarker v
                            && ((v |> BoundingBox2d.minY |> Quantity.equalWithin tolerance (box |> BoundingBox2d.minY))
                                    || (v |> BoundingBox2d.maxY |> Quantity.equalWithin tolerance (box |> BoundingBox2d.maxY))
                               )
                    )
                |> Maybe.withDefault False

        ( markers, lines ) =
            a |> List.partition isMark

        markersCount : Int
        markersCount =
            markers |> List.length

        markers_ : Markers
        markers_ =
            { xDistance =
                box
                    |> BoundingBox2d.dimensions
                    |> Tuple.first
                    |> Quantity.minus markerSize
                    |> Quantity.divideBy (toFloat (markersCount // 2 - 1))
            , yDistance =
                box
                    |> BoundingBox2d.dimensions
                    |> Tuple.second
                    |> Quantity.minus markerSize
            , count = markersCount // 2
            }
    in
    if markersCount < 4 || modBy 2 markersCount == 1 then
        Err InvalidMarkerCount

    else
        Ok
            ( lines
            , Just markers_
            )


markerSize : Length.Length
markerSize =
    Length.millimeters 3


tolerance : Length.Length
tolerance =
    Quantity.float 1 |> Quantity.at_ HP_GL.resolution


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

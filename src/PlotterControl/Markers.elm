module PlotterControl.Markers exposing (..)

import BoundingBox2d
import Dict
import HpGl
import Length
import List.Extra
import Point2d
import Polyline2d
import Quantity
import Rectangle2d
import SummaEl
import Vector2d


type alias Markers =
    { xDistance : Length.Length
    , yDistance : Length.Length
    , count : Int
    , loading : Loading
    }


fromPolylines :
    List (Polyline2d.Polyline2d Length.Meters ())
    -> Result Error ( List (Polyline2d.Polyline2d Length.Meters ()), Maybe Markers )
fromPolylines a =
    let
        firstMarkOffset : Polyline2d.Polyline2d Length.Meters coordinates -> Maybe (Point2d.Point2d Length.Meters coordinates)
        firstMarkOffset b =
            b
                |> Polyline2d.boundingBox
                |> Maybe.andThen
                    (\x ->
                        let
                            point : Point2d.Point2d Length.Meters coordinates
                            point =
                                Point2d.xy (BoundingBox2d.minX x) (BoundingBox2d.minY x)
                        in
                        if
                            boxHasSameSizeAsMarker x
                                && (point
                                        |> Point2d.xCoordinate
                                        |> Quantity.equalWithin (Length.millimeters 0.11) Quantity.zero
                                   )
                                && (point
                                        |> Point2d.yCoordinate
                                        |> Quantity.equalWithin (Length.millimeters 0.11) Quantity.zero
                                   )
                        then
                            Just point

                        else
                            Nothing
                    )
    in
    case a |> List.Extra.findMap firstMarkOffset of
        Just b ->
            let
                polylines : List (Polyline2d.Polyline2d Length.Meters ())
                polylines =
                    a |> List.map (Polyline2d.mapVertices (Point2d.translateBy (Vector2d.from b Point2d.origin)))
            in
            fromPolylinesHelper polylines

        Nothing ->
            Ok
                ( a
                , Nothing
                )


toSettings : Markers -> SummaEl.Settings
toSettings a =
    Dict.fromList
        [ ( "MARKER_X_DIS", a.xDistance |> HpGl.lengthToString )
        , ( "MARKER_Y_DIS", a.yDistance |> HpGl.lengthToString )
        , ( "MARKER_X_SIZE", size |> HpGl.lengthToString )
        , ( "MARKER_Y_SIZE", size |> HpGl.lengthToString )
        , ( "MARKER_X_N", a.count |> String.fromInt )
        , ( "OPOS_PANELLING"
          , case a.loading of
                LoadContinually ->
                    "ON"

                LoadSimultaneously ->
                    "OFF"
          )
        ]


boundingBox : Markers -> BoundingBox2d.BoundingBox2d Length.Meters coordinates
boundingBox a =
    BoundingBox2d.from
        Point2d.origin
        (Point2d.xy
            (a.xDistance |> Quantity.multiplyBy (toFloat (a.count - 1)) |> Quantity.plus size)
            (a.yDistance |> Quantity.plus size)
        )


rectangles : Markers -> List (Rectangle2d.Rectangle2d Length.Meters coordinates)
rectangles a =
    List.range 0 (a.count - 1)
        |> List.concatMap
            (\x ->
                let
                    rect : Point2d.Point2d Length.Meters coordinates -> Rectangle2d.Rectangle2d Length.Meters coordinates
                    rect b =
                        Rectangle2d.from b (b |> Point2d.translateBy (Vector2d.xy size size))

                    spacing : Vector2d.Vector2d Length.Meters coordinates
                    spacing =
                        Vector2d.xy
                            (a.xDistance |> Quantity.multiplyBy (toFloat x))
                            Quantity.zero
                in
                [ rect Point2d.origin
                    |> Rectangle2d.translateBy spacing
                , rect (Point2d.xy Quantity.zero a.yDistance)
                    |> Rectangle2d.translateBy spacing
                ]
            )


size : Length.Length
size =
    Length.millimeters 3


tolerance : Length.Length
tolerance =
    Quantity.float 1 |> Quantity.at_ HpGl.resolution



--


type Loading
    = LoadContinually
    | LoadSimultaneously



--


type Error
    = InvalidMarkerCount



--


boxHasSameSizeAsMarker : BoundingBox2d.BoundingBox2d Length.Meters coordinates -> Bool
boxHasSameSizeAsMarker a =
    a
        |> BoundingBox2d.dimensions
        |> (\( w, h ) ->
                (w |> Quantity.equalWithin tolerance size)
                    && (h |> Quantity.equalWithin tolerance size)
           )


fromPolylinesHelper :
    List (Polyline2d.Polyline2d Length.Meters coordinates)
    -> Result Error ( List (Polyline2d.Polyline2d Length.Meters coordinates), Maybe Markers )
fromPolylinesHelper a =
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

        ( markers, polylines ) =
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
                { xDistance = w |> Quantity.minus size |> Quantity.divideBy (toFloat (markersCount // 2 - 1))
                , yDistance = h |> Quantity.minus size
                , count = markersCount // 2
                , loading =
                    if markersCount > 4 then
                        LoadContinually

                    else
                        LoadSimultaneously
                }
        in
        Ok
            ( polylines
            , Just markers_
            )

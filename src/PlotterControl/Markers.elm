module PlotterControl.Markers exposing (..)

import BoundingBox2d
import Dict
import HpGl
import Length
import Polyline2d
import Quantity
import SummaEl


type alias Markers =
    { xDistance : Length.Length
    , yDistance : Length.Length
    , count : Int
    }


fromPolylines :
    List (Polyline2d.Polyline2d Length.Meters ())
    -> Result Error ( List (Polyline2d.Polyline2d Length.Meters ()), Maybe Markers )
fromPolylines a =
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
        fromPolylinesHelper a

    else
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
        ]


size : Length.Length
size =
    Length.millimeters 3


tolerance : Length.Length
tolerance =
    Quantity.float 1 |> Quantity.at_ HpGl.resolution



--


type Error
    = InvalidMarkerCount



--


boxHasSameSizeAsMarker : BoundingBox2d.BoundingBox2d Length.Meters coordinates -> Bool
boxHasSameSizeAsMarker b =
    b
        |> BoundingBox2d.dimensions
        |> (\( w, h ) ->
                (w |> Quantity.equalWithin tolerance size)
                    && (h |> Quantity.equalWithin tolerance size)
           )


fromPolylinesHelper :
    List (Polyline2d.Polyline2d Length.Meters coordinates)
    -> Result Error ( List (Polyline2d.Polyline2d Length.Meters coordinates), Maybe { xDistance : Quantity.Quantity Float Length.Meters, yDistance : Quantity.Quantity Float Length.Meters, count : Int } )
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
                { xDistance = w |> Quantity.minus size |> Quantity.divideBy (toFloat (markersCount // 2 - 1))
                , yDistance = h |> Quantity.minus size
                , count = markersCount // 2
                }
        in
        Ok
            ( lines
            , Just markers_
            )

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


type alias File =
    { name : Name
    , ready : Result Error Ready
    }


fromFile : File.File -> String -> Result Error File
fromFile a b =
    if a |> File.name |> String.endsWith ".hpgl" then
        fromHpGlFile a b

    else
        Err FileNotSupported


fromHpGlFile : File.File -> String -> Result Error File
fromHpGlFile a b =
    b
        |> HpGl.fromString
        |> Result.mapError ParserError
        |> Result.map HpGl.Geometry.polylines
        |> Result.andThen filterMarkers
        |> Result.map
            (\( polylines, markers ) ->
                { name = a |> File.name |> Name
                , polylines = polylines
                , markers = markers
                }
            )


toCommands : File -> { settings : SummaEl.SummaEl, data : HpGl.HpGl }
toCommands a =
    { settings =
        case a.markers of
            Just b ->
                [ SummaEl.SetSettings
                    (Dict.fromList
                        [ ( "MARKER_X_DIS", b.xDistance |> HpGl.lengthToString )
                        , ( "MARKER_Y_DIS", b.yDistance |> HpGl.lengthToString )
                        , ( "MARKER_X_SIZE", markerSize |> HpGl.lengthToString )
                        , ( "MARKER_Y_SIZE", markerSize |> HpGl.lengthToString )
                        , ( "MARKER_X_N", b.count |> String.fromInt )
                        ]
                    )
                , SummaEl.LoadMarkers
                ]

            Nothing ->
                []
    , data =
        a.polylines
            |> HpGl.Geometry.fromPolylines
            |> (\x -> [ HpGl.Initialize ] ++ x ++ [ HpGl.End ])
    }



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

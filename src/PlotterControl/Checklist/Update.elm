module PlotterControl.Checklist.Update exposing (..)

import Dict
import Dict.Any
import HpGl
import HpGl.Geometry
import Length
import LineSegment2d
import Platform.Extra
import PlotterControl.Checklist
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Page
import PlotterControl.Queue
import PlotterControl.Queue.Update
import PlotterControl.Settings
import Point2d
import Polyline2d
import Quantity
import Rectangle2d
import SummaEl
import Vector2d


activateChecklist : PlotterControl.Checklist.Checklist -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
activateChecklist a model =
    ( { model | page = Just (PlotterControl.Page.Checklist_ (PlotterControl.Page.Checklist a)) }
    , Cmd.none
    )


checkItem : PlotterControl.Checklist.Item -> Bool -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
checkItem item checked model =
    ( { model
        | checklist =
            if checked then
                Dict.Any.insert PlotterControl.Checklist.itemToComparable item () model.checklist

            else
                Dict.Any.remove PlotterControl.Checklist.itemToComparable item model.checklist
      }
    , Cmd.none
    )


resetChecklist : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
resetChecklist model =
    ( { model | checklist = Dict.Any.empty }
    , Cmd.none
    )



--


changeMarkerSensitivity : Int -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeMarkerSensitivity a model =
    let
        value : Int
        value =
            (case model.markerSensitivity of
                Just b ->
                    b + a

                Nothing ->
                    75
            )
                |> clamp 0 100

        level : Int
        level =
            value
                |> toFloat
                |> (\x -> x / 100)
                |> (\x -> 1 - x)
                |> (\x -> x * 250)
                |> round
    in
    ( { model | markerSensitivity = Just value }
    , Cmd.none
    )
        |> Platform.Extra.andThen
            (PlotterControl.Queue.Update.createItem
                (PlotterControl.Queue.stringToItemName "Set Sensitivity")
                (SummaEl.toString
                    [ SummaEl.SetSettings (Dict.singleton "OPOS_LEVEL" (String.fromInt level))
                    ]
                )
            )


testMarkers : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
testMarkers model =
    PlotterControl.Queue.Update.createItem
        (PlotterControl.Queue.stringToItemName "Marker Test")
        (SummaEl.toString [ SummaEl.LoadMarkers ])
        model



--


changeDrawingSpeed : Int -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeDrawingSpeed a model =
    let
        value : Int
        value =
            (case model.drawingSpeed of
                Just b ->
                    b + a

                Nothing ->
                    200
            )
                |> clamp 50 800
    in
    ( { model | drawingSpeed = Just value }
    , Cmd.none
    )
        |> Platform.Extra.andThen
            (PlotterControl.Queue.Update.createItem
                (PlotterControl.Queue.stringToItemName "Set Speed")
                (SummaEl.toString
                    (PlotterControl.Settings.presetToDefaultSettings PlotterControl.Settings.Draw
                        ++ [ SummaEl.SetSettings (Dict.singleton "VELOCITY" (String.fromInt value))
                           ]
                    )
                )
            )


changeDrawingPressure : Int -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeDrawingPressure a model =
    let
        value : Int
        value =
            (case model.drawingPressure of
                Just b ->
                    b + a

                Nothing ->
                    160
            )
                |> clamp 0 400
    in
    ( { model | drawingPressure = Just value }
    , Cmd.none
    )
        |> Platform.Extra.andThen
            (PlotterControl.Queue.Update.createItem
                (PlotterControl.Queue.stringToItemName "Set Pressure")
                (SummaEl.toString
                    (PlotterControl.Settings.presetToDefaultSettings PlotterControl.Settings.Draw
                        ++ [ SummaEl.SetSettings (Dict.singleton "PEN_PRESSURE" (String.fromInt value))
                           ]
                    )
                )
            )


testDrawing : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
testDrawing model =
    let
        size : Length.Length
        size =
            Length.millimeters 2

        spacing : Vector2d.Vector2d Length.Meters coordinates
        spacing =
            Vector2d.xy
                Quantity.zero
                (size |> Quantity.plus Length.millimeter)

        polyline : Polyline2d.Polyline2d Length.Meters coordinates
        polyline =
            Rectangle2d.from Point2d.origin (Point2d.xy size size)
                |> Rectangle2d.edges
                |> List.concatMap (\x -> [ LineSegment2d.startPoint x, LineSegment2d.endPoint x ])
                |> Polyline2d.fromVertices

        polylines : List (Polyline2d.Polyline2d Length.Meters coordinates)
        polylines =
            List.range 0 3
                |> List.map
                    (\i ->
                        Polyline2d.translateBy
                            (spacing |> Vector2d.scaleBy (toFloat i))
                            polyline
                    )

        test : String
        test =
            HpGl.toString (HpGl.Initialize :: HpGl.Geometry.fromPolylines polylines)
    in
    PlotterControl.Queue.Update.createItem
        (PlotterControl.Queue.stringToItemName "Drawing Test")
        (SummaEl.toString
            (PlotterControl.Settings.presetToDefaultSettings PlotterControl.Settings.Draw)
            ++ test
            ++ SummaEl.toString
                [ SummaEl.SetOrigin (Point2d.origin |> Point2d.translateBy spacing)
                ]
        )
        model

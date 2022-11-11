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
    ( { model | markerSensitivity = clamp 0 100 (model.markerSensitivity + a) }
    , Cmd.none
    )


testMarkers : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
testMarkers model =
    let
        level : Int
        level =
            model.markerSensitivity
                |> toFloat
                |> (\x -> x / 100)
                |> (\x -> 1 - x)
                |> (\x -> x * 250)
                |> round
                |> clamp 0 250
    in
    PlotterControl.Queue.Update.createItem
        (PlotterControl.Queue.stringToItemName "Marker Test")
        (SummaEl.toString
            [ SummaEl.SetSettings (Dict.singleton "OPOS_LEVEL" (String.fromInt level))
            , SummaEl.LoadMarkers
            ]
        )
        model



--


changeDrawingSpeed : Int -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeDrawingSpeed a model =
    ( { model | drawingSpeed = clamp 50 800 (model.drawingSpeed + a) }
    , Cmd.none
    )


changeDrawingPressure : Int -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeDrawingPressure a model =
    ( { model | drawingPressure = clamp 0 400 (model.drawingPressure + a) }
    , Cmd.none
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
            (PlotterControl.Settings.presetToDefaultSettings PlotterControl.Settings.Draw
                ++ [ SummaEl.SetSettings (Dict.singleton "VELOCITY" (String.fromInt model.drawingSpeed))
                   , SummaEl.SetSettings (Dict.singleton "PEN_PRESSURE" (String.fromInt model.drawingPressure))
                   ]
            )
            ++ test
            ++ SummaEl.toString
                [ SummaEl.SetOrigin (Point2d.origin |> Point2d.translateBy spacing)
                ]
        )
        model



--


changeCuttingPressure : Int -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeCuttingPressure a model =
    ( { model | cuttingPressure = clamp 0 400 (model.cuttingPressure + a) }
    , Cmd.none
    )


changeCuttingOffset : Int -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeCuttingOffset a model =
    ( { model | cuttingOffset = clamp 0 100 (model.cuttingOffset + a) }
    , Cmd.none
    )


testCutting : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
testCutting model =
    PlotterControl.Queue.Update.createItem
        (PlotterControl.Queue.stringToItemName "Cutting Test")
        (SummaEl.toString
            (PlotterControl.Settings.presetToDefaultSettings PlotterControl.Settings.Cut
                ++ [ SummaEl.SetSettings (Dict.singleton "KNIFE_PRESSURE" (String.fromInt model.cuttingPressure))
                   , SummaEl.SetSettings (Dict.singleton "DRAG_OFFSET" (String.fromInt model.cuttingOffset))
                   ]
            )
        )
        model



--


changePerforationPressure : Int -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changePerforationPressure a model =
    ( { model | perforationPressure = clamp 0 400 (model.perforationPressure + a) }
    , Cmd.none
    )


changePerforationOffset : Int -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changePerforationOffset a model =
    ( { model | perforationOffset = clamp 0 100 (model.perforationOffset + a) }
    , Cmd.none
    )


testPerforation : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
testPerforation model =
    Platform.Extra.noOperation model

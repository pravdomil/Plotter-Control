module PlotterControl.Checklist.Update exposing (..)

import Dict
import Dict.Any
import HpGl
import HpGl.Geometry
import Length
import LineSegment2d
import Mass
import PlotterControl.Checklist
import PlotterControl.MarkerSensitivity
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Page
import PlotterControl.Queue
import PlotterControl.Queue.Update
import PlotterControl.Settings
import PlotterControl.Utils.Utils
import Point2d
import Polyline2d
import Quantity
import Rectangle2d
import Speed
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



--


changeMarkerSensitivity : PlotterControl.MarkerSensitivity.MarkerSensitivity -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeMarkerSensitivity a model =
    ( { model
        | markerSensitivity =
            model.markerSensitivity
                |> Quantity.plus a
                |> Quantity.clamp
                    (PlotterControl.MarkerSensitivity.percentage 0)
                    (PlotterControl.MarkerSensitivity.percentage 100)
      }
    , Cmd.none
    )


testMarkers : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
testMarkers model =
    let
        settings : SummaEl.Settings
        settings =
            Dict.empty
                |> PlotterControl.Settings.setMarkerSensitivity model.markerSensitivity
                |> Dict.insert "OPOS_ORIGIN" "CURRENT_POSITION"

        params : String
        params =
            "("
                ++ PlotterControl.MarkerSensitivity.toString model.markerSensitivity
                ++ ")"
    in
    PlotterControl.Queue.Update.createItem
        (PlotterControl.Queue.stringToItemName ("Marker Test " ++ params))
        (SummaEl.toString
            ((PlotterControl.Settings.allPresets
                |> List.concatMap (PlotterControl.Settings.savePreset settings)
             )
                ++ [ SummaEl.LoadMarkers
                   ]
            )
        )
        model



--


changeDrawingSpeed : Speed.Speed -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeDrawingSpeed a model =
    ( { model
        | drawingSpeed =
            model.drawingSpeed
                |> Quantity.plus a
                |> Quantity.clamp
                    (PlotterControl.Utils.Utils.millimetersPerSecond 50)
                    (PlotterControl.Utils.Utils.millimetersPerSecond 800)
      }
    , Cmd.none
    )


changeDrawingPressure : Mass.Mass -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeDrawingPressure a model =
    ( { model
        | drawingPressure =
            model.drawingPressure
                |> Quantity.plus a
                |> Quantity.clamp
                    (Mass.grams 0)
                    (Mass.grams 400)
      }
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

        settings : SummaEl.Settings
        settings =
            PlotterControl.Settings.defaultSettings
                |> Dict.remove "OPOS_LEVEL"
                |> Dict.insert "OPOS_ORIGIN" "CURRENT_POSITION"
                --
                |> Dict.insert "TOOL" "PEN"
                |> Dict.insert "VELOCITY" (String.fromInt model.drawingSpeed)
                |> Dict.insert "PEN_PRESSURE" (String.fromInt model.drawingPressure)

        test : String
        test =
            HpGl.toString [ HpGl.ToolUp [ Point2d.origin ] ]
                ++ SummaEl.toString
                    (PlotterControl.Settings.savePreset settings PlotterControl.Settings.Draw)
                ++ HpGl.toString (HpGl.Geometry.fromPolylines polylines)
                ++ SummaEl.toString
                    [ SummaEl.SetOriginRelative (Point2d.origin |> Point2d.translateBy spacing)
                    ]
                ++ HpGl.toString [ HpGl.ToolUp [ Point2d.xy (Length.millimeters 40) Quantity.zero ] ]

        params : String
        params =
            "("
                ++ (String.fromInt model.drawingSpeed ++ " mm/s")
                ++ ", "
                ++ (String.fromInt model.drawingPressure ++ " g")
                ++ ")"
    in
    PlotterControl.Queue.Update.createItem (PlotterControl.Queue.stringToItemName ("Drawing Test " ++ params)) test model



--


changeCuttingSpeed : Speed.Speed -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeCuttingSpeed a model =
    ( { model
        | cuttingSpeed =
            model.cuttingSpeed
                |> Quantity.plus a
                |> Quantity.clamp
                    (PlotterControl.Utils.Utils.millimetersPerSecond 50)
                    (PlotterControl.Utils.Utils.millimetersPerSecond 800)
      }
    , Cmd.none
    )


changeCuttingPressure : Mass.Mass -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeCuttingPressure a model =
    ( { model
        | cuttingPressure =
            model.cuttingPressure
                |> Quantity.plus a
                |> Quantity.clamp
                    (Mass.grams 0)
                    (Mass.grams 400)
      }
    , Cmd.none
    )


changeCuttingOffset : Length.Length -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeCuttingOffset a model =
    ( { model
        | cuttingOffset =
            model.cuttingOffset
                |> Quantity.plus a
                |> Quantity.clamp
                    (Length.millimeters 0)
                    (Length.millimeters 1)
      }
    , Cmd.none
    )


testCutting : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
testCutting model =
    let
        polylines : List (Polyline2d.Polyline2d Length.Meters coordinates)
        polylines =
            [ Polyline2d.fromVertices
                [ Point2d.millimeters 0 0
                , Point2d.millimeters 10 0
                , Point2d.millimeters 10 5
                , Point2d.millimeters 0 5
                , Point2d.millimeters 0 10
                , Point2d.millimeters 10 10
                , Point2d.millimeters 10 5
                , Point2d.millimeters 0 5
                , Point2d.millimeters 0 0
                ]
            , Polyline2d.fromVertices
                [ Point2d.millimeters 2 2
                , Point2d.millimeters 8 8
                ]
            , Polyline2d.fromVertices
                [ Point2d.millimeters 2 8
                , Point2d.millimeters 8 2
                ]
            ]

        settings : SummaEl.Settings
        settings =
            PlotterControl.Settings.defaultSettings
                |> Dict.remove "OPOS_LEVEL"
                |> Dict.insert "OPOS_ORIGIN" "CURRENT_POSITION"
                --
                |> Dict.insert "OVERCUT" "2"
                |> Dict.insert "VELOCITY" (String.fromInt model.cuttingSpeed)
                |> Dict.insert "KNIFE_PRESSURE" (String.fromInt model.cuttingPressure)
                |> Dict.insert "DRAG_OFFSET" (String.fromInt model.cuttingOffset)

        test : String
        test =
            HpGl.toString [ HpGl.ToolUp [ Point2d.origin ] ]
                ++ SummaEl.toString
                    (PlotterControl.Settings.savePreset settings PlotterControl.Settings.Cut)
                ++ HpGl.toString (HpGl.Geometry.fromPolylines polylines)
                ++ SummaEl.toString
                    [ SummaEl.SetOriginRelative (Point2d.xy (Length.millimeters -8) (Length.millimeters (-2 + 11)))
                    ]
                ++ HpGl.toString [ HpGl.ToolUp [ Point2d.xy (Length.millimeters 40) Quantity.zero ] ]

        params : String
        params =
            "("
                ++ (String.fromInt model.cuttingSpeed ++ " mm/s")
                ++ ", "
                ++ (String.fromInt model.cuttingPressure ++ " g")
                ++ ", "
                ++ (String.fromFloat (toFloat model.cuttingOffset / 100) ++ " mm")
                ++ ")"
    in
    PlotterControl.Queue.Update.createItem (PlotterControl.Queue.stringToItemName ("Cutting Test " ++ params)) test model



--


changePerforationSpacing : Length.Length -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changePerforationSpacing a model =
    ( { model
        | perforationSpacing =
            model.perforationSpacing
                |> Quantity.plus a
                |> Quantity.clamp
                    (Length.millimeters 0)
                    (Length.millimeters 10)
      }
    , Cmd.none
    )


changePerforationOffset : Length.Length -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changePerforationOffset a model =
    ( { model
        | perforationOffset =
            model.perforationOffset
                |> Quantity.plus a
                |> Quantity.clamp
                    (Length.millimeters 0)
                    (Length.millimeters 1)
      }
    , Cmd.none
    )


testPerforation : PlotterControl.Msg.PerforationTest -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
testPerforation a model =
    let
        polylines : List (Polyline2d.Polyline2d Length.Meters coordinates)
        polylines =
            case a of
                PlotterControl.Msg.PerforationTestSquare ->
                    [ Polyline2d.fromVertices
                        [ Point2d.millimeters 16 0
                        , Point2d.millimeters 0 0
                        , Point2d.millimeters 0 16
                        ]
                    , Polyline2d.fromVertices
                        [ Point2d.millimeters 16 0
                        , Point2d.millimeters 16 16
                        , Point2d.millimeters 0 16
                        ]
                    ]

                PlotterControl.Msg.PerforationTestLine ->
                    [ Polyline2d.fromVertices
                        [ Point2d.millimeters 0 0
                        , Point2d.millimeters 0 16
                        ]
                    ]

        settings : SummaEl.Settings
        settings =
            PlotterControl.Settings.defaultSettings
                |> Dict.remove "OPOS_LEVEL"
                |> Dict.insert "OPOS_ORIGIN" "CURRENT_POSITION"
                --
                |> Dict.insert "FLEX_CUT" "MODE2"
                |> Dict.insert "FULL_PRESSURE" "400"
                |> Dict.insert "FLEX_VELOCITY" "100"
                |> Dict.insert "OVERCUT" "2"
                --
                |> Dict.insert "VELOCITY" (String.fromInt 800)
                |> Dict.insert "FLEX_LENGTH" (Length.millimeters (toFloat model.perforationSpacing / 10) |> SummaEl.lengthToString)
                |> Dict.insert "DRAG_OFFSET" (String.fromInt model.perforationOffset)

        test : String
        test =
            HpGl.toString [ HpGl.ToolUp [ Point2d.origin ] ]
                ++ SummaEl.toString
                    (PlotterControl.Settings.savePreset settings PlotterControl.Settings.Perforate)
                ++ HpGl.toString (HpGl.Geometry.fromPolylines polylines)
                ++ SummaEl.toString
                    [ SummaEl.SetOriginRelative (Point2d.xy (Length.millimeters 0) (Length.millimeters (-16 + 20)))
                    ]
                ++ HpGl.toString [ HpGl.ToolUp [ Point2d.xy (Length.millimeters 120) Quantity.zero ] ]

        params : String
        params =
            "("
                ++ (String.fromFloat (toFloat model.perforationSpacing / 10) ++ " mm")
                ++ ", "
                ++ (String.fromFloat (toFloat model.perforationOffset / 100) ++ " mm")
                ++ ")"
    in
    PlotterControl.Queue.Update.createItem (PlotterControl.Queue.stringToItemName ("Perforation Test " ++ params)) test model

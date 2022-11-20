module PlotterControl.Checklist.View exposing (..)

import Dict.Any
import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import Element.PravdomilUi.Application.Block
import Length
import Mass
import PlotterControl.Checklist
import PlotterControl.MarkerSensitivity
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Page
import PlotterControl.Utils.Theme exposing (..)
import PlotterControl.Utils.Utils
import PlotterControl.Utils.View


view : PlotterControl.Page.Checklist -> PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view a model =
    { size = \x -> { x | width = clamp 240 448 (x.width // 3) }
    , header =
        Just
            { attributes = []
            , left = []
            , center = textEllipsis [ fontCenter ] (PlotterControl.Checklist.toName a.checklist ++ " Checklist")
            , right = []
            }
    , toolbar = Nothing
    , body =
        Element.PravdomilUi.Application.Blocks
            [ viewChecklist model (PlotterControl.Checklist.items a.checklist)
            , case a.checklist of
                PlotterControl.Checklist.Media ->
                    Element.PravdomilUi.Application.Block.Empty

                PlotterControl.Checklist.Markers ->
                    markersTest model

                PlotterControl.Checklist.Drawing ->
                    drawingTest model

                PlotterControl.Checklist.Cutting ->
                    cuttingTest model

                PlotterControl.Checklist.Perforation ->
                    perforationTest model
            ]
    }


viewChecklist : PlotterControl.Model.Model -> List PlotterControl.Checklist.Item -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
viewChecklist model items =
    Element.PravdomilUi.Application.Block.Block
        (Just "Checklist")
        (items |> List.map (\x -> viewItem model x))


viewItem : PlotterControl.Model.Model -> PlotterControl.Checklist.Item -> Element PlotterControl.Msg.Msg
viewItem model a =
    let
        checkbox : Element PlotterControl.Msg.Msg -> Element PlotterControl.Msg.Msg
        checkbox b =
            inputCheckbox
                theme
                [ width fill ]
                { label = b
                , icon = inputCheckboxIcon theme
                , checked = Dict.Any.member PlotterControl.Checklist.itemToComparable a model.checklist
                , onChange = PlotterControl.Msg.ChecklistItemChecked a
                }
    in
    case a of
        PlotterControl.Checklist.MediaRollersInRange ->
            checkbox (text "Rollers are within white range.")

        PlotterControl.Checklist.MediaRollersAlignment ->
            checkbox (text "Medium and rollers are aligned.")

        PlotterControl.Checklist.MediaFlangeGuides ->
            checkbox (text "Media flange guides are locked.")

        PlotterControl.Checklist.MediaLeverArmDown ->
            checkbox (text "Lever arm is down.")

        --
        PlotterControl.Checklist.MarkersSensorClean ->
            checkbox (text "Sensor is cleaned with dust blaster.")

        PlotterControl.Checklist.MarkersTestOk ->
            checkbox (text "Marker test succeed.")

        --
        PlotterControl.Checklist.DrawingPenInHolder ->
            checkbox (text "Pen is in tool holder.")

        PlotterControl.Checklist.DrawingPenDepth ->
            checkbox (text "Pen depth is set.")

        PlotterControl.Checklist.DrawingTestOk ->
            checkbox (text "Drawing test succeed.")

        PlotterControl.Checklist.DrawingToolHolderKnob ->
            checkbox (text "Tool holder knob is tight.")

        --
        PlotterControl.Checklist.CuttingKnifeInHolder ->
            checkbox (text "Cutting knife is in tool holder.")

        PlotterControl.Checklist.CuttingKnifeDepth ->
            checkbox (text "Knife depth is set using 45° increments.")

        PlotterControl.Checklist.CuttingTestOk ->
            checkbox (text "Cutting test succeed.")

        PlotterControl.Checklist.CuttingKnifeSecureNut ->
            checkbox (text "Knife depth is secured with nut.")

        PlotterControl.Checklist.CuttingToolHolderKnob ->
            checkbox (text "Tool holder knob is tight.")

        --
        PlotterControl.Checklist.PerforationKnifeInHolder ->
            checkbox (text "Perforation knife is in tool holder.")

        PlotterControl.Checklist.PerforationToolDepth ->
            checkbox (text "Knife depth is set using 45° increments.")

        PlotterControl.Checklist.PerforationTestOk ->
            checkbox (text "Perforation test succeed.")

        PlotterControl.Checklist.PerforationKnifeSecureNut ->
            checkbox (text "Knife depth is secured with nut.")

        PlotterControl.Checklist.PerforationToolHolderKnob ->
            checkbox (text "Tool holder knob is tight.")



--


markersTest : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
markersTest model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Test")
        [ PlotterControl.Utils.View.inputHelper
            "Sensitivity:"
            (PlotterControl.MarkerSensitivity.toString model.markerSensitivity)
            none
            (PlotterControl.MarkerSensitivity.percentage 5)
            PlotterControl.Msg.MarkerSensitivityChanged
        , textButton theme
            [ centerX ]
            { label = text "Test Markers"
            , onPress = Just PlotterControl.Msg.MarkerTestRequested
            }
        ]



--


drawingTest : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
drawingTest model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Test")
        [ PlotterControl.Utils.View.inputHelper
            "Speed:"
            (PlotterControl.Utils.Utils.speedToString model.drawingSpeed)
            none
            (PlotterControl.Utils.Utils.millimetersPerSecond 50)
            PlotterControl.Msg.DrawingSpeedChanged
        , PlotterControl.Utils.View.inputHelper
            "Pressure:"
            (PlotterControl.Utils.Utils.massToString model.drawingPressure)
            none
            (Mass.grams 20)
            PlotterControl.Msg.DrawingPressureChanged
        , textButton theme
            [ centerX ]
            { label = text "Test Drawing"
            , onPress = Just PlotterControl.Msg.DrawingTestRequested
            }
        ]



--


cuttingTest : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
cuttingTest model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Test")
        [ PlotterControl.Utils.View.inputHelper
            "Speed:"
            (PlotterControl.Utils.Utils.speedToString model.cuttingSpeed)
            none
            (PlotterControl.Utils.Utils.millimetersPerSecond 50)
            PlotterControl.Msg.CuttingSpeedChanged
        , PlotterControl.Utils.View.inputHelper
            "Pressure:"
            (PlotterControl.Utils.Utils.massToString model.cuttingPressure)
            (text ("~" ++ PlotterControl.Utils.Utils.massToString PlotterControl.Utils.Utils.layerCutPressure ++ " / layer"))
            (Mass.grams 20)
            PlotterControl.Msg.CuttingPressureChanged
        , PlotterControl.Utils.View.inputHelper
            "Offset:"
            (PlotterControl.Utils.Utils.lengthToString model.cuttingOffset)
            none
            (Length.millimeters 0.1)
            PlotterControl.Msg.CuttingOffsetChanged
        , textButton theme
            [ centerX ]
            { label = text "Test Cutting"
            , onPress = Just PlotterControl.Msg.CuttingTestRequested
            }
        ]



--


perforationTest : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
perforationTest model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Test")
        [ PlotterControl.Utils.View.inputHelper
            "Spacing:"
            (PlotterControl.Utils.Utils.lengthToString model.perforationSpacing)
            none
            (Length.millimeters 0.2)
            PlotterControl.Msg.PerforationSpacingChanged
        , PlotterControl.Utils.View.inputHelper
            "Offset:"
            (PlotterControl.Utils.Utils.lengthToString model.perforationOffset)
            none
            (Length.millimeters 0.1)
            PlotterControl.Msg.PerforationOffsetChanged
        , textButton theme
            [ centerX ]
            { label = text "Test Perforation on Square"
            , onPress = Just (PlotterControl.Msg.PerforationTestRequested PlotterControl.Msg.PerforationTestSquare)
            }
        , textButton theme
            [ centerX ]
            { label = text "Test Perforation on Line"
            , onPress = Just (PlotterControl.Msg.PerforationTestRequested PlotterControl.Msg.PerforationTestLine)
            }
        ]

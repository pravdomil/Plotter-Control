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
            ]
    }


viewChecklist : PlotterControl.Model.Model -> List PlotterControl.Checklist.Item -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
viewChecklist model items =
    Element.PravdomilUi.Application.Block.Block
        (Just "Checklist")
        (items |> List.map (\x -> viewItem model x))


viewItem : PlotterControl.Model.Model -> PlotterControl.Checklist.Item -> Element PlotterControl.Msg.Msg
viewItem model a =
    case a of
        PlotterControl.Checklist.MediaRollersInRange ->
            checkbox model (text "Rollers are within white range.") a

        PlotterControl.Checklist.MediaRollersAlignment ->
            checkbox model (text "Medium and rollers are aligned.") a

        PlotterControl.Checklist.MediaFlangeGuides ->
            checkbox model (text "Media flange guides are locked.") a

        PlotterControl.Checklist.MediaLeverArmDown ->
            checkbox model (text "Lever arm is down.") a

        --
        PlotterControl.Checklist.MarkersSensorClean ->
            checkbox model (text "Sensor is cleaned with dust blaster.") a

        PlotterControl.Checklist.MarkersTestOk ->
            checkbox model (text "Marker test succeed.") a

        --
        PlotterControl.Checklist.DrawingPenInHolder ->
            checkbox model (text "Pen is in tool holder.") a

        PlotterControl.Checklist.DrawingPenDepth ->
            checkbox model (text "Pen depth is set.") a

        PlotterControl.Checklist.DrawingTestOk ->
            checkbox model (text "Drawing test succeed.") a

        PlotterControl.Checklist.DrawingToolHolderKnob ->
            checkbox model (text "Tool holder knob is tight.") a

        --
        PlotterControl.Checklist.CuttingKnifeInHolder ->
            checkbox model (text "Cutting knife is in tool holder.") a

        PlotterControl.Checklist.CuttingTestOk ->
            cuttingTest model

        PlotterControl.Checklist.CuttingKnifeSecureNut ->
            checkbox model (text "Knife depth is secured with nut.") a

        PlotterControl.Checklist.CuttingToolHolderKnob ->
            checkbox model (text "Tool holder knob is tight.") a

        --
        PlotterControl.Checklist.PerforationKnifeInHolder ->
            checkbox model (text "Perforation knife is in tool holder.") a

        PlotterControl.Checklist.PerforationTestOk ->
            perforationTest model

        PlotterControl.Checklist.PerforationKnifeSecureNut ->
            checkbox model (text "Knife depth is secured with nut.") a

        PlotterControl.Checklist.PerforationToolHolderKnob ->
            checkbox model (text "Tool holder knob is tight.") a


checkbox : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg -> PlotterControl.Checklist.Item -> Element PlotterControl.Msg.Msg
checkbox model label a =
    inputCheckbox theme
        [ width fill ]
        { label = label
        , icon = inputCheckboxIcon theme
        , checked = Dict.Any.member PlotterControl.Checklist.itemToComparable a model.checklist
        , onChange = PlotterControl.Msg.ChecklistItemChecked a
        }



--


markersTest : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
markersTest model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Test")
        [ PlotterControl.Utils.View.quantityInput
            "Sensitivity:"
            (PlotterControl.MarkerSensitivity.toString model.markerSensitivity)
            none
            (PlotterControl.MarkerSensitivity.percentage 5)
            PlotterControl.Msg.MarkerSensitivityChanged
        , button theme
            [ centerX ]
            { label = text "Test Markers"
            , active = False
            , onPress = Just PlotterControl.Msg.MarkerTestRequested
            }
        ]



--


drawingTest : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
drawingTest model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Test")
        [ PlotterControl.Utils.View.quantityInput
            "Speed:"
            (PlotterControl.Utils.Utils.speedToString model.drawingSpeed)
            none
            (PlotterControl.Utils.Utils.millimetersPerSecond 50)
            PlotterControl.Msg.DrawingSpeedChanged
        , PlotterControl.Utils.View.quantityInput
            "Pressure:"
            (PlotterControl.Utils.Utils.massToString model.drawingPressure)
            none
            (Mass.grams 20)
            PlotterControl.Msg.DrawingPressureChanged
        , button theme
            [ centerX ]
            { label = text "Test Drawing"
            , active = False
            , onPress = Just PlotterControl.Msg.DrawingTestRequested
            }
        ]



--


cuttingTest : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
cuttingTest model =
    column [ width fill, spacing 8 ]
        [ checkbox model (text "Cutting test succeed.") PlotterControl.Checklist.CuttingTestOk
        , PlotterControl.Utils.View.twoColumns
            "Knife Depth:"
            (text "Set manually")
        , PlotterControl.Utils.View.quantityInput
            "Speed:"
            (PlotterControl.Utils.Utils.speedToString model.cuttingSpeed)
            none
            (PlotterControl.Utils.Utils.millimetersPerSecond 50)
            PlotterControl.Msg.CuttingSpeedChanged
        , PlotterControl.Utils.View.quantityInput
            "Pressure:"
            (PlotterControl.Utils.Utils.massToString model.cuttingPressure)
            none
            (Mass.grams 20)
            PlotterControl.Msg.CuttingPressureChanged
        , PlotterControl.Utils.View.quantityInput
            "Offset:"
            (PlotterControl.Utils.Utils.lengthToString model.cuttingOffset)
            none
            (Length.millimeters 0.05)
            PlotterControl.Msg.CuttingOffsetChanged
        , button theme
            [ centerX ]
            { label = text "Test Cutting"
            , active = False
            , onPress = Just PlotterControl.Msg.CuttingTestRequested
            }
        ]


perforationTest : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
perforationTest model =
    column [ width fill, spacing 8 ]
        [ checkbox model (text "Perforation test succeed.") PlotterControl.Checklist.PerforationTestOk
        , PlotterControl.Utils.View.twoColumns
            "Knife Depth:"
            (text "Set manually")
        , PlotterControl.Utils.View.quantityInput
            "Spacing:"
            (PlotterControl.Utils.Utils.lengthToString model.perforationSpacing)
            none
            (Length.millimeters 0.2)
            PlotterControl.Msg.PerforationSpacingChanged
        , PlotterControl.Utils.View.quantityInput
            "Offset:"
            (PlotterControl.Utils.Utils.lengthToString model.perforationOffset)
            none
            (Length.millimeters 0.05)
            PlotterControl.Msg.PerforationOffsetChanged
        , button theme
            [ centerX ]
            { label = text "Test Perforation"
            , active = False
            , onPress = Just PlotterControl.Msg.PerforationTestRequested
            }
        ]

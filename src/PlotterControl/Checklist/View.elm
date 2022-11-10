module PlotterControl.Checklist.View exposing (..)

import Dict.Any
import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import Element.PravdomilUi.Application.Block
import PlotterControl.Checklist
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Page
import PlotterControl.Utils.Theme exposing (..)


view : PlotterControl.Page.Checklist -> PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view a model =
    { size = \x -> { x | width = max 240 (x.width // 3) }
    , header =
        Just
            { attributes = []
            , left = []
            , center = textEllipsis [ fontCenter ] "Checklist"
            , right =
                [ textButton theme
                    [ fontSemiBold ]
                    { label = text "Reset"
                    , onPress = Just PlotterControl.Msg.ResetChecklist
                    }
                ]
            }
    , toolbar = Nothing
    , body =
        Element.PravdomilUi.Application.Blocks
            [ case a.checklist of
                PlotterControl.Checklist.MediaChecklist ->
                    viewChecklist model "Media" PlotterControl.Checklist.mediaChecklist

                PlotterControl.Checklist.MarkersChecklist ->
                    viewChecklist model "Markers" PlotterControl.Checklist.markersChecklist

                PlotterControl.Checklist.DrawingChecklist ->
                    viewChecklist model "Drawing" PlotterControl.Checklist.drawingChecklist

                PlotterControl.Checklist.CuttingChecklist ->
                    viewChecklist model "Cutting" PlotterControl.Checklist.cuttingChecklist

                PlotterControl.Checklist.PerforationChecklist ->
                    viewChecklist model "Perforation" PlotterControl.Checklist.perforationChecklist
            ]
    }


viewChecklist : PlotterControl.Model.Model -> String -> List PlotterControl.Checklist.Item -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
viewChecklist model label items =
    Element.PravdomilUi.Application.Block.Block
        (Just label)
        (items
            |> List.map
                (\x ->
                    viewItem (model.checklist |> Dict.Any.member PlotterControl.Checklist.toComparable x) x
                )
        )


viewItem : Bool -> PlotterControl.Checklist.Item -> Element PlotterControl.Msg.Msg
viewItem checked a =
    inputCheckbox
        theme
        [ width fill ]
        { label = viewLabel a
        , icon = inputCheckboxIcon theme
        , checked = checked
        , onChange = PlotterControl.Msg.ChecklistItemChecked a
        }


viewLabel : PlotterControl.Checklist.Item -> Element PlotterControl.Msg.Msg
viewLabel a =
    case a of
        PlotterControl.Checklist.MediaRollersAlignment ->
            text "Medium and rollers are aligned."

        PlotterControl.Checklist.MediaFlangeGuides ->
            text "Flange guides are locked."

        PlotterControl.Checklist.MediaLeverArmDown ->
            text "Lever arm is down."

        --
        PlotterControl.Checklist.MarkersTestOk ->
            text "Marker test succeed."

        --
        PlotterControl.Checklist.DrawingPenInHolder ->
            text "Drawing pen is in tool holder."

        PlotterControl.Checklist.DrawingPenPressure ->
            text "Pen pressure is ok."

        PlotterControl.Checklist.DrawingPenDepth ->
            text "Pen depth is ok."

        PlotterControl.Checklist.DrawingToolHolderKnob ->
            text "Tool holder knob is tight."

        --
        PlotterControl.Checklist.CuttingKnifeInHolder ->
            text "Cutting knife is in tool holder."

        PlotterControl.Checklist.CuttingKnifePressure ->
            text "Knife pressure is ok."

        PlotterControl.Checklist.CuttingKnifeDepth ->
            text "Knife depth is ok."

        PlotterControl.Checklist.CuttingKnifeSecureNut ->
            text "Knife depth is secured with nut."

        PlotterControl.Checklist.CuttingToolHolderKnob ->
            text "Tool holder knob is tight."

        PlotterControl.Checklist.CuttingKnifeOffset ->
            text "Knife offset is corrected."

        --
        PlotterControl.Checklist.PerforationKnifeInHolder ->
            text "Perforation knife is in tool holder."

        PlotterControl.Checklist.PerforationToolDepth ->
            text "Knife depth is ok."

        PlotterControl.Checklist.PerforationFlexPressure ->
            text "Flex pressure is just enough."

        PlotterControl.Checklist.PerforationKnifeSecureNut ->
            text "Knife depth is secured with nut."

        PlotterControl.Checklist.PerforationToolHolderKnob ->
            text "Tool holder knob is tight."

        PlotterControl.Checklist.PerforationToolOffset ->
            text "Knife offset is corrected."

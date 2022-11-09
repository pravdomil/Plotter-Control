module PlotterControl.Checklist.View exposing (..)

import Dict.Any
import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import Element.PravdomilUi.Application.Block
import PlotterControl.Checklist
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Utils.Theme exposing (..)


view : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view model =
    { size = \x -> { x | width = max 240 (x.width // 4) }
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
            [ viewChecklist model "Media Load" PlotterControl.Checklist.loadChecklist
            , viewChecklist model "Markers Calibration" PlotterControl.Checklist.markersChecklist
            , viewChecklist model "Draw Calibration" PlotterControl.Checklist.drawChecklist
            , viewChecklist model "Cut Calibration" PlotterControl.Checklist.cutChecklist
            , viewChecklist model "Perforation Calibration" PlotterControl.Checklist.perforationChecklist
            ]
    }


viewChecklist : PlotterControl.Model.Model -> String -> List PlotterControl.Checklist.Item -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
viewChecklist model label items =
    Element.PravdomilUi.Application.Block.Block
        (Just label)
        (items
            |> List.map
                (\x ->
                    viewItem (model.checkList |> Dict.Any.member PlotterControl.Checklist.toComparable x) x
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
        PlotterControl.Checklist.LoadMediumRollersAlignment ->
            text "Medium and rollers are aligned."

        PlotterControl.Checklist.LoadMediaFlangesLock ->
            text "Media flanges are secured."

        PlotterControl.Checklist.LoadLeverArmDown ->
            text "Lever arm is down."

        PlotterControl.Checklist.LoadMarkersCalibration ->
            text "Markers are calibrated."

        PlotterControl.Checklist.LoadPresetCalibration ->
            text "Preset is calibrated."

        --
        PlotterControl.Checklist.MarkersTestOk ->
            text "Marker test succeed."

        --
        PlotterControl.Checklist.DrawPenInHolder ->
            text "Drawing pen is in tool holder."

        PlotterControl.Checklist.DrawPenPressure ->
            text "Pen pressure is ok."

        PlotterControl.Checklist.DrawPenDepth ->
            text "Pen depth is ok."

        PlotterControl.Checklist.DrawToolHolderKnob ->
            text "Tool holder knob is tight."

        --
        PlotterControl.Checklist.CutKnifeInHolder ->
            text "Cutting knife is in tool holder."

        PlotterControl.Checklist.CutKnifePressure ->
            text "Knife pressure is ok."

        PlotterControl.Checklist.CutKnifeDepth ->
            text "Knife depth is ok."

        PlotterControl.Checklist.CutKnifeSecureNut ->
            text "Knife depth is secured with nut."

        PlotterControl.Checklist.CutToolHolderKnob ->
            text "Tool holder knob is tight."

        PlotterControl.Checklist.CutKnifeOffset ->
            text "Knife offset is corrected."

        --
        PlotterControl.Checklist.PerfKnifeInHolder ->
            text "Perforation knife is in tool holder."

        PlotterControl.Checklist.PerfToolDepth ->
            text "Knife depth is ok."

        PlotterControl.Checklist.PerfFlexPressure ->
            text "Flex pressure is just enough."

        PlotterControl.Checklist.PerfKnifeSecureNut ->
            text "Knife depth is secured with nut."

        PlotterControl.Checklist.PerfToolHolderKnob ->
            text "Tool holder knob is tight."

        PlotterControl.Checklist.PerfToolOffset ->
            text "Knife offset is corrected."

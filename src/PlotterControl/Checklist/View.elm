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
    let
        name : String
        name =
            PlotterControl.Checklist.toName a.checklist
    in
    { size = \x -> { x | width = max 240 (x.width // 3) }
    , header =
        Just
            { attributes = []
            , left = []
            , center = textEllipsis [ fontCenter ] (name ++ " Checklist")
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
            [ viewChecklist model name (PlotterControl.Checklist.items a.checklist)
            ]
    }


viewChecklist : PlotterControl.Model.Model -> String -> List PlotterControl.Checklist.Item -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
viewChecklist model label items =
    Element.PravdomilUi.Application.Block.Block
        (Just label)
        (items
            |> List.map
                (\x ->
                    viewItem (model.checklist |> Dict.Any.member PlotterControl.Checklist.itemToComparable x) x
                )
        )


viewItem : Bool -> PlotterControl.Checklist.Item -> Element PlotterControl.Msg.Msg
viewItem checked a =
    let
        checkbox : Element PlotterControl.Msg.Msg -> Element PlotterControl.Msg.Msg
        checkbox b =
            inputCheckbox
                theme
                [ width fill ]
                { label = b
                , icon = inputCheckboxIcon theme
                , checked = checked
                , onChange = PlotterControl.Msg.ChecklistItemChecked a
                }
    in
    case a of
        PlotterControl.Checklist.MediaRollersInRange ->
            checkbox (text "Rollers are within white range.")

        PlotterControl.Checklist.MediaRollersAlignment ->
            checkbox (text "Medium and rollers are aligned.")

        PlotterControl.Checklist.MediaFlangeGuides ->
            checkbox (text "Flange guides are locked.")

        PlotterControl.Checklist.MediaLeverArmDown ->
            checkbox (text "Lever arm is down.")

        --
        PlotterControl.Checklist.MarkersTestOk ->
            checkbox (text "Marker test succeed.")

        --
        PlotterControl.Checklist.DrawingPenInHolder ->
            checkbox (text "Drawing pen is in tool holder.")

        PlotterControl.Checklist.DrawingPenPressure ->
            checkbox (text "Pen pressure is ok.")

        PlotterControl.Checklist.DrawingPenDepth ->
            checkbox (text "Pen depth is ok.")

        PlotterControl.Checklist.DrawingToolHolderKnob ->
            checkbox (text "Tool holder knob is tight.")

        --
        PlotterControl.Checklist.CuttingKnifeInHolder ->
            checkbox (text "Cutting knife is in tool holder.")

        PlotterControl.Checklist.CuttingKnifePressure ->
            checkbox (text "Knife pressure is ok.")

        PlotterControl.Checklist.CuttingKnifeDepth ->
            checkbox (text "Knife depth is ok.")

        PlotterControl.Checklist.CuttingKnifeSecureNut ->
            checkbox (text "Knife depth is secured with nut.")

        PlotterControl.Checklist.CuttingToolHolderKnob ->
            checkbox (text "Tool holder knob is tight.")

        PlotterControl.Checklist.CuttingKnifeOffset ->
            checkbox (text "Knife offset is corrected.")

        --
        PlotterControl.Checklist.PerforationKnifeInHolder ->
            checkbox (text "Perforation knife is in tool holder.")

        PlotterControl.Checklist.PerforationToolDepth ->
            checkbox (text "Knife depth is ok.")

        PlotterControl.Checklist.PerforationFlexPressure ->
            checkbox (text "Flex pressure is just enough.")

        PlotterControl.Checklist.PerforationKnifeSecureNut ->
            checkbox (text "Knife depth is secured with nut.")

        PlotterControl.Checklist.PerforationToolHolderKnob ->
            checkbox (text "Tool holder knob is tight.")

        PlotterControl.Checklist.PerforationToolOffset ->
            checkbox (text "Knife offset is corrected.")

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
            [ viewChecklist model "Roll Load" PlotterControl.Checklist.rollChecklist
            , viewChecklist model "Media Calibration" PlotterControl.Checklist.mediaChecklist
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
viewItem checked item =
    let
        label : Element msg
        label =
            case item of
                PlotterControl.Checklist.ToolDepth ->
                    text "Tool depth is ok."

                PlotterControl.Checklist.ToolHolderKnob ->
                    text "Tool holder knob is tight."

                PlotterControl.Checklist.ToolOffset ->
                    text "Tool offset is corrected."

                PlotterControl.Checklist.ToolPressure ->
                    text "Tool pressure is ok."

                PlotterControl.Checklist.ToolVelocity ->
                    text "Tool velocity is ok."

                PlotterControl.Checklist.RollRollersAlignment ->
                    text "Roll and rollers are aligned."

                PlotterControl.Checklist.RollGuidesLock ->
                    text "Roll is secured with guides."

                PlotterControl.Checklist.KnifeSecureNut ->
                    text "Knife depth is secured with nut."

                PlotterControl.Checklist.MarkerSensitivity ->
                    text "Marker test succeed."

                PlotterControl.Checklist.FlexPressure ->
                    text "Flex pressure is just enough."

                PlotterControl.Checklist.RollerLeverArmDown ->
                    text "Lever arm is down."

                PlotterControl.Checklist.CutKnife ->
                    text "Cutting knife is in tool holder."

                PlotterControl.Checklist.PerforationKnife ->
                    text "Perforation knife is in tool holder."
    in
    inputCheckbox
        theme
        [ width fill ]
        { label = label
        , icon = inputCheckboxIcon theme
        , checked = checked
        , onChange = PlotterControl.Msg.ChecklistItemChecked item
        }

module PlotterControl.Checklist.View exposing (..)

import Dict.Any
import Element.PravdomilUi exposing (..)
import PlotterControl.Checklist
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Utils.Theme exposing (..)


view : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
view model =
    column [ width fill, spacing 16, padding 16 ]
        [ row [ width fill, spacing 8 ]
            [ heading1 theme
                []
                [ text "Checklist"
                ]
            , el [ width fill ] none
            , textButton theme
                []
                { label = text "Reset"
                , onPress = Just PlotterControl.Msg.ResetChecklist
                }
            ]
        , viewChecklist model (text "Roll") PlotterControl.Checklist.rollChecklist
        , viewChecklist model (text "Markers") PlotterControl.Checklist.markersChecklist
        , viewChecklist model (text "Cut") PlotterControl.Checklist.cutChecklist
        , viewChecklist model (text "Perforation") PlotterControl.Checklist.perforationChecklist
        ]


viewChecklist : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg -> List PlotterControl.Checklist.Item -> Element PlotterControl.Msg.Msg
viewChecklist model label items =
    column [ width fill, spacing 8 ]
        [ el (theme.label []) label
        , column [ width fill ]
            (items
                |> List.map
                    (\x ->
                        viewItem (model.checkList |> Dict.Any.member PlotterControl.Checklist.toComparable x) x
                    )
            )
        ]


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

                PlotterControl.Checklist.RollAlignment ->
                    text "Roll is aligned."

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
    in
    inputCheckbox
        theme
        [ width fill ]
        { label = label
        , icon = inputCheckboxIcon theme
        , checked = checked
        , onChange = PlotterControl.Msg.ChecklistItemChecked item
        }

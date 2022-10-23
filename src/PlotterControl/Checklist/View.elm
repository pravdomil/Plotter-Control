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
        [ heading1 theme
            []
            [ text "Checklist"
            ]
        , column [ width fill ]
            (PlotterControl.Checklist.items
                |> List.map
                    (\x ->
                        viewItem
                            (model.checkList |> Dict.Any.member PlotterControl.Checklist.toComparable x)
                            x
                    )
            )
        ]


viewItem : Bool -> PlotterControl.Checklist.Item -> Element PlotterControl.Msg.Msg
viewItem checked item =
    let
        label : Element msg
        label =
            case item of
                PlotterControl.Checklist.RollAlignment ->
                    text "Roll Alignment"

                PlotterControl.Checklist.RollGuidesLock ->
                    text "Roll Guides Lock"

                PlotterControl.Checklist.ToolOffset ->
                    text "Tool Offset"

                PlotterControl.Checklist.ToolPressure ->
                    text "Tool Pressure"

                PlotterControl.Checklist.ToolDepth ->
                    text "Tool Depth"

                PlotterControl.Checklist.ToolVelocity ->
                    text "Tool Velocity"

                PlotterControl.Checklist.MarkerSensitivity ->
                    text "Marker Sensitivity"

                PlotterControl.Checklist.KnifeSecureNut ->
                    text "Knife Secure Nut"

                PlotterControl.Checklist.ToolHolderKnob ->
                    text "Tool Holder Knob"
    in
    inputCheckbox
        theme
        [ width fill ]
        { label = label
        , icon = inputCheckboxIcon theme
        , checked = checked
        , onChange = PlotterControl.Msg.ChecklistItemChecked item
        }

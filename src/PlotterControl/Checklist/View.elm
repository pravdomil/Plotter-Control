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
        , viewChecklist
            model
            (text "For Roll")
            PlotterControl.Checklist.rollChecklist
        , viewChecklist
            model
            (text "For Markers")
            PlotterControl.Checklist.markersChecklist
        , viewChecklist
            model
            (text "For Cut")
            PlotterControl.Checklist.cutChecklist
        , viewChecklist
            model
            (text "For Perforation")
            PlotterControl.Checklist.perforationChecklist
        ]


viewChecklist : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg -> List PlotterControl.Checklist.Item -> Element PlotterControl.Msg.Msg
viewChecklist model label items =
    column [ width fill ]
        (items
            |> List.map (\x -> viewItem (model.checkList |> Dict.Any.member PlotterControl.Checklist.toComparable x) x)
            |> (\x -> el (theme.label []) label :: x)
        )


viewItem : Bool -> PlotterControl.Checklist.Item -> Element PlotterControl.Msg.Msg
viewItem checked item =
    let
        label : Element msg
        label =
            case item of
                PlotterControl.Checklist.ToolDepth ->
                    text "Tool Depth"

                PlotterControl.Checklist.ToolHolderKnob ->
                    text "Tool Holder Knob"

                PlotterControl.Checklist.ToolOffset ->
                    text "Tool Offset"

                PlotterControl.Checklist.ToolPressure ->
                    text "Tool Pressure"

                PlotterControl.Checklist.ToolVelocity ->
                    text "Tool Velocity"

                PlotterControl.Checklist.RollAlignment ->
                    text "Roll Alignment"

                PlotterControl.Checklist.RollGuidesLock ->
                    text "Roll Guides Lock"

                PlotterControl.Checklist.KnifeSecureNut ->
                    text "Knife Secure Nut"

                PlotterControl.Checklist.MarkerSensitivity ->
                    text "Marker Sensitivity"

                PlotterControl.Checklist.FlexPressure ->
                    text "Flex Pressure"
    in
    inputCheckbox
        theme
        [ width fill ]
        { label = label
        , icon = inputCheckboxIcon theme
        , checked = checked
        , onChange = PlotterControl.Msg.ChecklistItemChecked item
        }

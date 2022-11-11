module PlotterControl.Checklist.View exposing (..)

import Dict.Any
import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import Element.PravdomilUi.Application.Block
import FeatherIcons
import PlotterControl.Checklist
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Page
import PlotterControl.Utils.Theme exposing (..)
import PlotterControl.Utils.View


view : PlotterControl.Page.Checklist -> PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view a model =
    { size = \x -> { x | width = clamp 240 448 (x.width // 3) }
    , header =
        Just
            { attributes = []
            , left = []
            , center = textEllipsis [ fontCenter ] (PlotterControl.Checklist.toName a.checklist ++ " Checklist")
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
            checkbox (text "Sensor cleaned with dust blaster.")

        PlotterControl.Checklist.MarkersTestOk ->
            checkbox (text "Marker test succeed.")

        --
        PlotterControl.Checklist.DrawingPenInHolder ->
            checkbox (text "Pen is in tool holder.")

        PlotterControl.Checklist.DrawingPenDepth ->
            checkbox (text "Pen depth is set.")

        PlotterControl.Checklist.DrawingToolHolderKnob ->
            checkbox (text "Tool holder knob is tight.")

        PlotterControl.Checklist.DrawingTestOk ->
            checkbox (text "Drawing test succeed.")

        --
        PlotterControl.Checklist.CuttingKnifeInHolder ->
            checkbox (text "Cutting knife is in tool holder.")

        PlotterControl.Checklist.CuttingKnifeDepth ->
            checkbox (text "Knife depth is set.")

        PlotterControl.Checklist.CuttingKnifeSecureNut ->
            checkbox (text "Knife depth is secured with nut.")

        PlotterControl.Checklist.CuttingToolHolderKnob ->
            checkbox (text "Tool holder knob is tight.")

        PlotterControl.Checklist.CuttingTestOk ->
            checkbox (text "Cutting test succeed.")

        --
        PlotterControl.Checklist.PerforationKnifeInHolder ->
            checkbox (text "Perforation knife is in tool holder.")

        PlotterControl.Checklist.PerforationToolDepth ->
            checkbox (text "Knife depth is set.")

        PlotterControl.Checklist.PerforationKnifeSecureNut ->
            checkbox (text "Knife depth is secured with nut.")

        PlotterControl.Checklist.PerforationToolHolderKnob ->
            checkbox (text "Tool holder knob is tight.")

        PlotterControl.Checklist.PerforationTestOk ->
            checkbox (text "Perforation test succeed.")



--


markersTest : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
markersTest model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Test")
        [ inputHelper
            "Sensitivity:"
            (String.fromInt model.markerSensitivity ++ "%")
            (PlotterControl.Msg.MarkerSensitivityChanged 5)
            (PlotterControl.Msg.MarkerSensitivityChanged -5)
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
        [ inputHelper
            "Speed:"
            (String.fromInt model.drawingSpeed ++ " mm/s")
            (PlotterControl.Msg.DrawingSpeedChanged 50)
            (PlotterControl.Msg.DrawingSpeedChanged -50)
        , inputHelper
            "Pressure:"
            (String.fromInt model.drawingPressure ++ " g")
            (PlotterControl.Msg.DrawingPressureChanged 20)
            (PlotterControl.Msg.DrawingPressureChanged -20)
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
        [ inputHelper
            "Speed:"
            (String.fromInt model.cuttingSpeed ++ " mm/s")
            (PlotterControl.Msg.CuttingSpeedChanged 50)
            (PlotterControl.Msg.CuttingSpeedChanged -50)
        , inputHelper
            "Pressure:"
            (String.fromInt model.cuttingPressure ++ " g")
            (PlotterControl.Msg.CuttingPressureChanged 20)
            (PlotterControl.Msg.CuttingPressureChanged -20)
        , inputHelper
            "Offset:"
            (String.fromFloat (toFloat model.cuttingOffset / 100) ++ " mm")
            (PlotterControl.Msg.CuttingOffsetChanged 10)
            (PlotterControl.Msg.CuttingOffsetChanged -10)
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
        [ inputHelper
            "Pressure:"
            (String.fromInt model.perforationPressure ++ " g")
            (PlotterControl.Msg.PerforationPressureChanged 20)
            (PlotterControl.Msg.PerforationPressureChanged -20)
        , inputHelper
            "Offset:"
            (String.fromFloat (toFloat model.perforationOffset / 100) ++ " mm")
            (PlotterControl.Msg.PerforationOffsetChanged 10)
            (PlotterControl.Msg.PerforationOffsetChanged -10)
        , textButton theme
            [ centerX ]
            { label = text "Test Perforation"
            , onPress = Just PlotterControl.Msg.PerforationTestRequested
            }
        ]



--


inputHelper : String -> String -> msg -> msg -> Element msg
inputHelper label value plus minus =
    PlotterControl.Utils.View.twoColumns
        label
        (row [ spacing 8 ]
            [ el [ fontVariant fontTabularNumbers ] (text value)
            , textButton theme
                []
                { label = FeatherIcons.minus |> FeatherIcons.withSize 20 |> PlotterControl.Utils.View.iconToElement
                , onPress = Just minus
                }
            , textButton theme
                []
                { label = FeatherIcons.plus |> FeatherIcons.withSize 20 |> PlotterControl.Utils.View.iconToElement
                , onPress = Just plus
                }
            ]
        )

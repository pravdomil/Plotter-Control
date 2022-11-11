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
                    Element.PravdomilUi.Application.Block.Empty

                PlotterControl.Checklist.Cutting ->
                    Element.PravdomilUi.Application.Block.Empty

                PlotterControl.Checklist.Perforation ->
                    Element.PravdomilUi.Application.Block.Empty
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
            checkbox (text "Drawing pen is in tool holder.")

        PlotterControl.Checklist.DrawingSpeed ->
            column [ width fill, spacing 8 ]
                [ checkbox (text "Speed is set.")
                , PlotterControl.Utils.View.twoColumns
                    "Speed:"
                    (row [ spacing 8 ]
                        [ el [ fontVariant fontTabularNumbers ]
                            (text
                                (model.drawingSpeed
                                    |> Maybe.map String.fromInt
                                    |> Maybe.withDefault "000"
                                    |> (\x -> x ++ " mm/s")
                                )
                            )
                        , textButton theme
                            []
                            { label = FeatherIcons.minus |> FeatherIcons.withSize 20 |> PlotterControl.Utils.View.iconToElement
                            , onPress = PlotterControl.Msg.DrawingSpeedChanged -50 |> Just
                            }
                        , textButton theme
                            []
                            { label = FeatherIcons.plus |> FeatherIcons.withSize 20 |> PlotterControl.Utils.View.iconToElement
                            , onPress = PlotterControl.Msg.DrawingSpeedChanged 50 |> Just
                            }
                        ]
                    )
                , statusText theme
                    [ fontCenter ]
                    "Recommended speed is 200 mm/s."
                ]

        PlotterControl.Checklist.DrawingPenPressure ->
            column [ width fill, spacing 8 ]
                [ checkbox (text "Pen pressure is set.")
                , PlotterControl.Utils.View.twoColumns
                    "Pressure:"
                    (row [ spacing 8 ]
                        [ el [ fontVariant fontTabularNumbers ]
                            (text
                                (model.drawingPressure
                                    |> Maybe.map String.fromInt
                                    |> Maybe.withDefault "000"
                                    |> (\x -> x ++ " g")
                                )
                            )
                        , textButton theme
                            []
                            { label = FeatherIcons.minus |> FeatherIcons.withSize 20 |> PlotterControl.Utils.View.iconToElement
                            , onPress = PlotterControl.Msg.DrawingPressureChanged -20 |> Just
                            }
                        , textButton theme
                            []
                            { label = FeatherIcons.plus |> FeatherIcons.withSize 20 |> PlotterControl.Utils.View.iconToElement
                            , onPress = PlotterControl.Msg.DrawingPressureChanged 20 |> Just
                            }
                        ]
                    )
                , statusText theme
                    [ fontCenter ]
                    "Recommended pressure is 160 g."
                ]

        PlotterControl.Checklist.DrawingPenDepth ->
            checkbox (text "Pen depth is set.")

        PlotterControl.Checklist.DrawingToolHolderKnob ->
            checkbox (text "Tool holder knob is tight.")

        PlotterControl.Checklist.DrawingTestOk ->
            column [ width fill, spacing 8 ]
                [ checkbox (text "Drawing test succeed.")
                , textButton theme
                    [ centerX ]
                    { label = text "Drawing Test"
                    , onPress = Just PlotterControl.Msg.DrawingTestRequested
                    }
                ]

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


markersTest : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
markersTest model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Test")
        [ PlotterControl.Utils.View.twoColumns
            "Sensitivity:"
            (row [ spacing 8 ]
                [ el [ fontVariant fontTabularNumbers ]
                    (text
                        (String.fromInt model.markerSensitivity ++ "%")
                    )
                , textButton theme
                    []
                    { label = FeatherIcons.minus |> FeatherIcons.withSize 20 |> PlotterControl.Utils.View.iconToElement
                    , onPress = PlotterControl.Msg.MarkerSensitivityChanged -5 |> Just
                    }
                , textButton theme
                    []
                    { label = FeatherIcons.plus |> FeatherIcons.withSize 20 |> PlotterControl.Utils.View.iconToElement
                    , onPress = PlotterControl.Msg.MarkerSensitivityChanged 5 |> Just
                    }
                ]
            )
        , textButton theme
            [ centerX ]
            { label = text "Test Markers"
            , onPress = Just PlotterControl.Msg.MarkerTestRequested
            }
        ]

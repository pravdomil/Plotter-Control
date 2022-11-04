module PlotterControl.Settings.View exposing (..)

import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application.Block
import Length
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Settings
import PlotterControl.Utils.Theme exposing (..)
import PlotterControl.Utils.Utils
import PlotterControl.Utils.View


view : PlotterControl.Model.Model -> PlotterControl.File.Name -> PlotterControl.Settings.Settings -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
view _ a b =
    Element.PravdomilUi.Application.Block.Block
        (Just "Settings")
        [ preset a b
        , markerLoading a b
        , copies a b
        , copyDistance a b
        ]


preset : PlotterControl.File.Name -> PlotterControl.Settings.Settings -> Element PlotterControl.Msg.Msg
preset name a =
    PlotterControl.Utils.View.twoRows
        (text "Preset:")
        (row [ spacing 8 ]
            [ inputRadioRow theme
                []
                { label = labelHidden "Preset:"
                , options =
                    [ inputRadioBlockOption theme [] PlotterControl.Settings.Cut (text "Cut")
                    , inputRadioBlockOption theme [] PlotterControl.Settings.Draw (text "Draw")
                    , inputRadioBlockOption theme [] PlotterControl.Settings.Perforate (text "Perforate")
                    ]
                , selected = Just a.preset
                , onChange = PlotterControl.Msg.PresetChanged name
                }
            , textButton theme
                []
                { label = text "Configure"
                , onPress = Just (PlotterControl.Msg.ConfigurePlotterRequested name)
                }
            ]
        )


markerLoading : PlotterControl.File.Name -> PlotterControl.Settings.Settings -> Element PlotterControl.Msg.Msg
markerLoading name a =
    PlotterControl.Utils.View.twoRows
        (text "Marker Loading:")
        (inputRadioRow theme
            []
            { label = labelHidden "Marker Loading:"
            , options =
                [ inputRadioBlockOption theme [] PlotterControl.Settings.LoadSequentially (text "Sequentially")
                , inputRadioBlockOption theme [] PlotterControl.Settings.LoadAllAtOnce (text "All at Once")
                ]
            , selected = Just a.markerLoading
            , onChange = PlotterControl.Msg.MarkerLoadingChanged name
            }
        )


copies : PlotterControl.File.Name -> PlotterControl.Settings.Settings -> Element PlotterControl.Msg.Msg
copies name a =
    PlotterControl.Utils.View.twoRows
        (text "Copies:")
        (PlotterControl.Utils.View.inputNumber
            (text (a.copies |> PlotterControl.Settings.copiesToInt |> String.fromInt))
            (\x -> x |> PlotterControl.Settings.intToCopies |> PlotterControl.Msg.CopiesChanged name)
        )


copyDistance : PlotterControl.File.Name -> PlotterControl.Settings.Settings -> Element PlotterControl.Msg.Msg
copyDistance name a =
    PlotterControl.Utils.View.twoRows
        (text "Copy Distance:")
        (PlotterControl.Utils.View.inputNumber
            (text (PlotterControl.Utils.Utils.mmToString a.copyDistance))
            (\x -> x |> toFloat |> Length.millimeters |> PlotterControl.Msg.CopyDistanceChanged name)
        )

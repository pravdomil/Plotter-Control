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
    PlotterControl.Utils.View.twoColumns
        "Preset:"
        (inputRadioRow theme
            []
            { label = labelHidden "Preset:"
            , options =
                PlotterControl.Settings.allPresets
                    |> List.map (\x -> inputRadioBlockOption theme [] x (text (PlotterControl.Settings.presetName x)))
            , selected = Just a.preset
            , onChange = PlotterControl.Msg.PresetChanged name
            }
        )


markerLoading : PlotterControl.File.Name -> PlotterControl.Settings.Settings -> Element PlotterControl.Msg.Msg
markerLoading name a =
    PlotterControl.Utils.View.twoColumns
        "Marker Loading:"
        (inputRadioRow theme
            []
            { label = labelHidden "Marker Loading:"
            , options =
                [ inputRadioBlockOption theme [] PlotterControl.Settings.LoadContinually (text "Continually")
                , inputRadioBlockOption theme [] PlotterControl.Settings.LoadSimultaneously (text "Simultaneously")
                ]
            , selected = Just a.markerLoading
            , onChange = PlotterControl.Msg.MarkerLoadingChanged name
            }
        )


copies : PlotterControl.File.Name -> PlotterControl.Settings.Settings -> Element PlotterControl.Msg.Msg
copies name a =
    PlotterControl.Utils.View.twoColumns
        "Copies:"
        (PlotterControl.Utils.View.inputNumber
            (text (a.copies |> PlotterControl.Settings.copiesToInt |> String.fromInt))
            (\x -> x |> PlotterControl.Settings.intToCopies |> PlotterControl.Msg.CopiesChanged name)
        )


copyDistance : PlotterControl.File.Name -> PlotterControl.Settings.Settings -> Element PlotterControl.Msg.Msg
copyDistance name a =
    PlotterControl.Utils.View.twoColumns
        "Copy Distance:"
        (PlotterControl.Utils.View.inputNumber
            (text (PlotterControl.Utils.Utils.mmToString a.copyDistance))
            (\x -> x |> toFloat |> Length.millimeters |> PlotterControl.Msg.CopyDistanceChanged name)
        )

module PlotterControl.Commander.View exposing (..)

import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import Element.PravdomilUi.Application.Block
import Length
import PlotterControl.Commander
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Utils.Theme exposing (..)
import PlotterControl.Utils.Utils
import PlotterControl.Utils.View


view : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view model =
    { size = \x -> { x | width = clamp 240 448 (x.width // 3) }
    , header =
        Just
            { attributes = []
            , left = []
            , center = text "Commander"
            , right = []
            }
    , toolbar = Nothing
    , body =
        Element.PravdomilUi.Application.Blocks
            [ Element.PravdomilUi.Application.Block.Block (Just "Command")
                [ PlotterControl.Utils.View.twoColumns "Type:"
                    (inputRadioRow theme
                        [ width fill ]
                        { label = labelHidden "Type:"
                        , options =
                            PlotterControl.Commander.allCommandTypes
                                |> List.map
                                    (\x ->
                                        inputRadioBlockOption theme [ width fill ] x (textEllipsis [] (PlotterControl.Commander.commandTypeToName x))
                                    )
                        , selected = Just model.commander.type_
                        , onChange = PlotterControl.Msg.CommanderCommandTypeChanged
                        }
                    )
                , inputMultiline theme
                    []
                    { label = labelHidden "Command"
                    , placeholder = Nothing
                    , text = model.commander.command
                    , spellcheck = False
                    , onChange = PlotterControl.Msg.CommanderCommandChanged
                    }
                , button theme
                    [ fontSemiBold, centerX ]
                    { label = text "Enqueue"
                    , active = False
                    , onPress = Just PlotterControl.Msg.CommanderSendRequested
                    }
                , statusText theme [] "To enter service mode press left & right & enter on startup."
                ]
            , Element.PravdomilUi.Application.Block.Block (Just "Marker Sensor Calibration")
                [ PlotterControl.Utils.View.quantityInput
                    "Left Offset:"
                    (PlotterControl.Utils.Utils.lengthToString model.commander.sensorLeftOffset)
                    none
                    (Length.millimeters 0.1)
                    PlotterControl.Msg.CommanderSensorLeftOffsetChanged
                , PlotterControl.Utils.View.quantityInput
                    "Up Offset:"
                    (PlotterControl.Utils.Utils.lengthToString model.commander.sensorUpOffset)
                    none
                    (Length.millimeters 0.1)
                    PlotterControl.Msg.CommanderSensorUpOffsetChanged
                , button theme
                    [ fontSemiBold, centerX ]
                    { label = text "Calibrate"
                    , active = False
                    , onPress = Just PlotterControl.Msg.CommanderSensorCalibrateRequested
                    }
                ]
            ]
    }

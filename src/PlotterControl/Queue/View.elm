module PlotterControl.Queue.View exposing (..)

import Dict.Any
import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import Element.PravdomilUi.Application.Block
import FeatherIcons
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter
import PlotterControl.Queue
import PlotterControl.Utils.Theme exposing (..)
import PlotterControl.Utils.View
import Time
import Usb.Device
import WakeLock


view : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view model =
    { size = \x -> { x | width = max 240 (x.width // 4) }
    , header =
        Just
            { attributes = []
            , left = []
            , center = textEllipsis [ fontCenter ] "Queue"
            , right =
                [ mainButton model
                ]
            }
    , toolbar = Nothing
    , body =
        Element.PravdomilUi.Application.Blocks
            [ plotterStatus model
            , case model.queue |> Dict.Any.isEmpty of
                True ->
                    Element.PravdomilUi.Application.Block.Status
                        [ text "Queue is empty."
                        ]

                False ->
                    Element.PravdomilUi.Application.Block.Block
                        (Just "Items")
                        [ inputRadio theme
                            [ width fill ]
                            { label = labelHidden "Items"
                            , options =
                                model.queue
                                    |> Dict.Any.toList
                                    |> List.sortBy (\( _, x ) -> x.created |> Time.posixToMillis)
                                    |> List.map
                                        (\( id, x ) ->
                                            inputRadioBlockOption
                                                theme
                                                [ width fill ]
                                                id
                                                (row [ width fill ]
                                                    [ textEllipsis [] (PlotterControl.Queue.itemNameToString x.name)
                                                    , textButton theme
                                                        []
                                                        { label = FeatherIcons.x |> PlotterControl.Utils.View.iconToElement
                                                        , onPress = Just (PlotterControl.Msg.QueueItemRemoveRequested id)
                                                        }
                                                    ]
                                                )
                                        )
                            , selected = Nothing
                            , onChange = always PlotterControl.Msg.NothingHappened
                            }
                        ]
            ]
    }


mainButton : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
mainButton model =
    let
        sendButton : Element PlotterControl.Msg.Msg
        sendButton =
            textButton theme
                [ fontSemiBold ]
                { label = text "Send"
                , onPress = Just PlotterControl.Msg.SendQueueRequested
                }

        stopButton : Element PlotterControl.Msg.Msg
        stopButton =
            textButton theme
                [ fontSemiBold, bgColor style.danger ]
                { label = text "Stop"
                , onPress = Just PlotterControl.Msg.StopSendingRequested
                }
    in
    if model.queue |> Dict.Any.isEmpty then
        none

    else
        case model.plotter of
            Ok _ ->
                sendButton

            Err b ->
                case b of
                    PlotterControl.Model.NoPlotter ->
                        sendButton

                    PlotterControl.Model.PlotterConnecting ->
                        none

                    PlotterControl.Model.PlotterSending _ ->
                        stopButton

                    PlotterControl.Model.PlotterError _ ->
                        sendButton


plotterStatus : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
plotterStatus model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Status")
        [ paragraph theme
            [ paddingXY 8 8 ]
            [ case model.plotter of
                Ok _ ->
                    text "Ready."

                Err b ->
                    case b of
                        PlotterControl.Model.NoPlotter ->
                            text "Ready."

                        PlotterControl.Model.PlotterConnecting ->
                            text "Connecting..."

                        PlotterControl.Model.PlotterSending _ ->
                            text "Sending..."

                        PlotterControl.Model.PlotterError c ->
                            case c of
                                PlotterControl.Plotter.UsbDeviceError d ->
                                    case d of
                                        Usb.Device.NotSupported ->
                                            text "Your browser is not supported."

                                        Usb.Device.NothingSelected ->
                                            text "Ready."

                                        Usb.Device.TransferAborted ->
                                            text "Sending has been stopped."

                                        Usb.Device.JavaScriptError _ ->
                                            text "Internal error."

                                PlotterControl.Plotter.WakeLockError d ->
                                    case d of
                                        WakeLock.JavaScriptError _ ->
                                            text "Internal error."
            ]
        ]

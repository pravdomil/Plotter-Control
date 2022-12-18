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
    { size = \x -> { x | width = clamp 240 448 (x.width // 3) }
    , header =
        Just
            { attributes = []
            , left =
                [ mainButton model
                ]
            , center = textEllipsis [ fontCenter ] "Queue"
            , right =
                [ case model.queue |> Dict.Any.isEmpty of
                    True ->
                        el [] none

                    False ->
                        textButton theme
                            []
                            { label = text "Download"
                            , onPress = Just PlotterControl.Msg.QueueDownloadRequested
                            }
                ]
            }
    , toolbar = Nothing
    , body =
        Element.PravdomilUi.Application.Blocks
            [ plotterStatus model
            , Element.PravdomilUi.Application.Block.Block
                (Just "Items")
                (case model.queue |> Dict.Any.isEmpty of
                    True ->
                        [ statusText theme
                            [ paddingXY 8 0 ]
                            "Queue is empty."
                        ]

                    False ->
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
                                                        [ height fill ]
                                                        { label = FeatherIcons.x |> FeatherIcons.withSize 20 |> PlotterControl.Utils.View.iconToElement
                                                        , onPress = Just (PlotterControl.Msg.QueueItemRemoveRequested id)
                                                        }
                                                    ]
                                                )
                                        )
                            , selected = Nothing
                            , onChange = always PlotterControl.Msg.NothingHappened
                            }
                        ]
                )
            ]
    }


mainButton : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
mainButton model =
    let
        sendButton : Element PlotterControl.Msg.Msg
        sendButton =
            if model.queue |> Dict.Any.isEmpty then
                el [] none

            else
                textButton theme
                    [ fontSemiBold ]
                    { label = text "Send"
                    , onPress = Just PlotterControl.Msg.SendQueueRequested
                    }

        stopButton : Element PlotterControl.Msg.Msg
        stopButton =
            textButton theme
                [ fontSemiBold, fontColor style.danger ]
                { label = text "Stop"
                , onPress = Just PlotterControl.Msg.StopSendingRequested
                }
    in
    case model.plotter of
        Ok _ ->
            sendButton

        Err b ->
            case b of
                PlotterControl.Model.NoPlotter ->
                    sendButton

                PlotterControl.Model.PlotterConnecting ->
                    el [] none

                PlotterControl.Model.PlotterSending _ ->
                    stopButton

                PlotterControl.Model.PlotterError _ ->
                    sendButton


plotterStatus : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
plotterStatus model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Status")
        [ statusText theme
            [ paddingXY 8 0 ]
            (case model.plotter of
                Ok _ ->
                    "Ready."

                Err b ->
                    case b of
                        PlotterControl.Model.NoPlotter ->
                            "Ready."

                        PlotterControl.Model.PlotterConnecting ->
                            "Connecting..."

                        PlotterControl.Model.PlotterSending _ ->
                            "Sending..."

                        PlotterControl.Model.PlotterError c ->
                            case c of
                                PlotterControl.Plotter.UsbDeviceError d ->
                                    case d of
                                        Usb.Device.NotSupported ->
                                            "Your browser is not supported."

                                        Usb.Device.NothingSelected ->
                                            "Ready."

                                        Usb.Device.DeviceDisconnected ->
                                            "Disconnected."

                                        Usb.Device.TransferAborted ->
                                            "Sending has been stopped."

                                        Usb.Device.JavaScriptError _ ->
                                            "Internal error."

                                PlotterControl.Plotter.WakeLockError d ->
                                    case d of
                                        WakeLock.PageNotVisible ->
                                            "Please keep application visible."

                                        WakeLock.JavaScriptError _ ->
                                            "Internal error."
            )
        ]

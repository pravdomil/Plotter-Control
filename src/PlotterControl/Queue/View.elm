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
            , right = []
            }
    , toolbar = Nothing
    , body =
        Element.PravdomilUi.Application.Blocks
            (case model.queue |> Dict.Any.isEmpty of
                True ->
                    [ Element.PravdomilUi.Application.Block.Status
                        [ text "Queue is empty."
                        ]
                    ]

                False ->
                    [ Element.PravdomilUi.Application.Block.Block
                        (Just "Items")
                        [ plotterStatus model
                        , inputRadio theme
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
            )
    }


plotterStatus : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
plotterStatus model =
    let
        sendButton : Element PlotterControl.Msg.Msg
        sendButton =
            button theme
                []
                { label = text "Send Queue"
                , onPress = Just PlotterControl.Msg.SendQueueRequested
                }

        stopButton : Element PlotterControl.Msg.Msg
        stopButton =
            button theme
                [ bgColor style.danger ]
                { label = text "Stop Sending"
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
                    statusParagraph theme
                        []
                        [ text "Connecting..."
                        ]

                PlotterControl.Model.PlotterSending _ ->
                    stopButton

                PlotterControl.Model.PlotterError c ->
                    column [ spacing 16 ]
                        [ sendButton
                        , statusParagraph theme
                            []
                            [ case c of
                                PlotterControl.Plotter.UsbDeviceError d ->
                                    case d of
                                        Usb.Device.NotSupported ->
                                            text "Your browser is not supported."

                                        Usb.Device.NothingSelected ->
                                            none

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

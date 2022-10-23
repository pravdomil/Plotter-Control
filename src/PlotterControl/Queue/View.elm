module PlotterControl.Queue.View exposing (..)

import Dict.Any
import Element.PravdomilUi exposing (..)
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


view : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
view model =
    column [ width fill, spacing 16, padding 16 ]
        [ heading1 theme
            []
            [ text "Queue"
            ]
        , case model.queue |> Dict.Any.isEmpty of
            True ->
                statusParagraph theme
                    []
                    [ text "Is empty."
                    ]

            False ->
                column [ width fill, spacing 16 ]
                    [ plotterStatus model
                    , inputRadio theme
                        [ width fill ]
                        { label = labelAbove theme [ paddingEach 0 0 0 8 ] (text "Items")
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

                PlotterControl.Model.PlotterSending ->
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

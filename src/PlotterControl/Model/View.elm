module PlotterControl.Model.View exposing (..)

import Browser
import Element.PravdomilUi exposing (..)
import FeatherIcons
import File
import Html.Events
import Json.Decode
import Length
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter
import PlotterControl.Settings
import PlotterControl.Utils.Theme exposing (..)
import Usb.Device
import WakeLock


view : PlotterControl.Model.Model -> Browser.Document PlotterControl.Msg.Msg
view model =
    { title = "Plotter Control"
    , body =
        [ layout theme [] (lazy viewDropArea model)
        ]
    }


viewDropArea : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
viewDropArea model =
    el
        [ width fill
        , height fill
        , onDragOver PlotterControl.Msg.DragOver
        , onDrop PlotterControl.Msg.GotFile
        ]
        (viewInterface model)


viewInterface : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
viewInterface model =
    column
        [ alignTop
        , centerX
        , spacing 24
        , padding 32
        ]
        [ form
            (heading1 theme
                []
                [ text "Plotter"
                ]
            )
            (heading1 theme
                []
                [ text "Control"
                ]
            )
        , form
            (el (theme.label [ width fill, fontAlignRight ]) (text "File:"))
            (row [ spacing 8 ]
                [ case model.file of
                    Ok b ->
                        paragraph theme
                            []
                            [ text (b.name |> (\(PlotterControl.File.Name x) -> x))
                            ]

                    Err b ->
                        case b of
                            PlotterControl.Model.NotAsked ->
                                none

                            PlotterControl.Model.Loading ->
                                text "Loading..."

                            PlotterControl.Model.FileError c ->
                                case c of
                                    PlotterControl.File.FileNotSupported ->
                                        text "File type is not supported."

                                    PlotterControl.File.InvalidMarkerCount ->
                                        text "Failed to load markers."

                                    PlotterControl.File.ParserError _ ->
                                        text "Failed to parse file."
                , textButton theme
                    []
                    { label = text "Select"
                    , onPress = Just PlotterControl.Msg.OpenFile
                    }
                ]
            )
        , form
            (el (theme.label [ width fill, fontAlignRight ]) (text "Markers:"))
            (case model.file |> Result.toMaybe |> Maybe.andThen .markers of
                Just a ->
                    row [ spacing 8 ]
                        [ text
                            ([ a.count |> String.fromInt
                             , a.yDistance |> mmToString
                             , a.xDistance |> mmToString
                             ]
                                |> String.join " × "
                            )
                        , textButton theme
                            []
                            { label = text "Test"
                            , onPress = Just PlotterControl.Msg.TestMarkers
                            }
                        ]

                Nothing ->
                    text "None"
            )
        , form (el (theme.label [ width fill, fontAlignRight ]) (text "Preset:"))
            (column [ spacing 8 ]
                [ inputRadio theme
                    [ spacing 8 ]
                    { label = labelHidden "Preset:"
                    , options =
                        [ inputRadioBlockOption theme [] PlotterControl.Settings.Cut (text "Cut")
                        , inputRadioBlockOption theme [] PlotterControl.Settings.Draw (text "Draw")
                        , inputRadioBlockOption theme [] PlotterControl.Settings.Perforate (text "Perforate")
                        ]
                    , selected = Just model.settings.preset
                    , onChange = PlotterControl.Msg.ChangePreset
                    }
                , paragraph theme
                    [ fontSize 14 ]
                    [ text "Set depth, pressure, offset, velocity, sensitivity on plotter."
                    ]
                ]
            )
        , case Ok () of
            Ok _ ->
                form
                    (el (theme.label [ width fill, fontAlignRight ]) (text "Marker loading:"))
                    (inputRadio theme
                        [ spacing 8 ]
                        { label = labelHidden "Marker loading:"
                        , options =
                            [ inputRadioBlockOption theme [] PlotterControl.Settings.LoadAllAtOnce (text "All at Once")
                            , inputRadioBlockOption theme [] PlotterControl.Settings.LoadSequentially (text "Sequentially")
                            ]
                        , selected = Just model.settings.markerLoading
                        , onChange = PlotterControl.Msg.ChangeMarkerLoading
                        }
                    )

            Err _ ->
                none
        , inputNumber
            { label = el (theme.label [ width fill, fontAlignRight ]) (text "Copies:")
            , value =
                el [ fontVariant fontTabularNumbers ]
                    (text
                        (model.settings.copies
                            |> (\(PlotterControl.Settings.Copies x) -> x)
                            |> String.fromInt
                        )
                    )
            , onChange = PlotterControl.Settings.Copies >> PlotterControl.Msg.PlusCopies
            }
        , inputNumber
            { label = el (theme.label [ width fill, fontAlignRight ]) (text "Distance between copies:")
            , value =
                el [ fontVariant fontTabularNumbers ]
                    (text (mmToString model.settings.copyDistance))
            , onChange = toFloat >> Length.millimeters >> PlotterControl.Msg.PlusCopyDistance
            }
        , form
            none
            (let
                sendButton : Element PlotterControl.Msg.Msg
                sendButton =
                    case model.file of
                        Ok _ ->
                            button theme
                                [ paddingXY 16 12 ]
                                { label = text "Send File"
                                , onPress = Just PlotterControl.Msg.SendFile
                                }

                        Err _ ->
                            none

                cancelButton : Element PlotterControl.Msg.Msg
                cancelButton =
                    button theme
                        [ paddingXY 16 12, bgColor style.danger ]
                        { label = text "Stop"
                        , onPress = Just PlotterControl.Msg.StopSending
                        }
             in
             column [ spacing 8 ]
                (case model.plotter of
                    Ok _ ->
                        [ cancelButton
                        , text "Sending..."
                        ]

                    Err b ->
                        case b of
                            PlotterControl.Model.Ready ->
                                [ sendButton
                                ]

                            PlotterControl.Model.Connecting ->
                                [ text "Connecting..."
                                ]

                            PlotterControl.Model.FileSent ->
                                [ sendButton
                                , text "File sent."
                                ]

                            PlotterControl.Model.PlotterError c ->
                                [ sendButton
                                , case c of
                                    PlotterControl.Plotter.USBDeviceError d ->
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
                )
            )
        ]



--


inputNumber : { label : Element msg, value : Element msg, onChange : Int -> msg } -> Element msg
inputNumber config =
    form
        config.label
        (row [ spacing 8 ]
            [ textButton theme
                []
                { label = FeatherIcons.minus |> FeatherIcons.withSize 30 |> FeatherIcons.toHtml [] |> html
                , onPress = config.onChange -10 |> Just
                }
            , textButton theme
                []
                { label = FeatherIcons.minus |> FeatherIcons.withSize 20 |> FeatherIcons.toHtml [] |> html
                , onPress = config.onChange -1 |> Just
                }
            , config.value
            , textButton theme
                []
                { label = FeatherIcons.plus |> FeatherIcons.withSize 20 |> FeatherIcons.toHtml [] |> html
                , onPress = config.onChange 1 |> Just
                }
            , textButton theme
                []
                { label = FeatherIcons.plus |> FeatherIcons.withSize 30 |> FeatherIcons.toHtml [] |> html
                , onPress = config.onChange 10 |> Just
                }
            ]
        )



--


form : Element msg -> Element msg -> Element msg
form a b =
    row [ spacing 8 ]
        [ el [ width (px 320), fontAlignRight ] a
        , el [ width (px 320) ] b
        ]



--


onDragOver : msg -> Attribute msg
onDragOver msg =
    Html.Events.preventDefaultOn
        "dragover"
        (Json.Decode.succeed ( msg, True ))
        |> htmlAttribute


onDrop : (File.File -> msg) -> Attribute msg
onDrop msg =
    Html.Events.preventDefaultOn
        "drop"
        (Json.Decode.at [ "dataTransfer", "files", "0" ] File.decoder
            |> Json.Decode.map (\x -> ( msg x, True ))
        )
        |> htmlAttribute



--


mmToString : Length.Length -> String
mmToString a =
    a
        |> Length.inMillimeters
        |> (*) 10
        |> round
        |> toFloat
        |> (\x -> x / 10)
        |> String.fromFloat
        |> (\x -> x ++ " mm")

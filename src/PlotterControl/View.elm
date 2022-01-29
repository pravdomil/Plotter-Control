module PlotterControl.View exposing (..)

import Browser
import Element.PravdomilUI exposing (..)
import FeatherIcons
import File
import Html.Events
import Json.Decode
import Length
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.SerialPort
import PlotterControl.Settings
import PlotterControl.UI exposing (..)
import SerialPort
import WakeLock


view : PlotterControl.Model.Model -> Browser.Document PlotterControl.Model.Msg
view model =
    { title = "Plotter Control"
    , body =
        [ layout theme [] (lazy viewDropArea model)
        ]
    }


viewDropArea : PlotterControl.Model.Model -> Element PlotterControl.Model.Msg
viewDropArea model =
    el
        [ width fill
        , height fill
        , onDragOver PlotterControl.Model.DragOver
        , onDrop PlotterControl.Model.GotFile
        ]
        (viewInterface model)


viewInterface : PlotterControl.Model.Model -> Element PlotterControl.Model.Msg
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
            (el (theme.label ++ [ width fill, fontAlignRight ]) (text "File:"))
            (row [ spacing 8 ]
                [ case model.file of
                    Ok b ->
                        paragraph theme
                            []
                            [ text (b.name |> (\(PlotterControl.File.Name v) -> v))
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
                , linkWithOnPress theme
                    []
                    { label = text "Select"
                    , onPress = Just PlotterControl.Model.OpenFile
                    }
                ]
            )
        , form
            (el (theme.label ++ [ width fill, fontAlignRight ]) (text "Markers:"))
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
                        , linkWithOnPress theme
                            []
                            { label = text "Test"
                            , onPress = Just PlotterControl.Model.TestMarkers
                            }
                        ]

                Nothing ->
                    text "None"
            )
        , form (el (theme.label ++ [ width fill, fontAlignRight ]) (text "Preset:"))
            (column [ spacing 8 ]
                [ inputRadio [ spacing 8 ]
                    { label = labelHidden "Preset:"
                    , options =
                        [ inputOption PlotterControl.Settings.Cut (text "Cut")
                        , inputOption PlotterControl.Settings.Draw (text "Draw")
                        , inputOption PlotterControl.Settings.Perforate (text "Perforate")
                        ]
                    , selected = Just model.settings.preset
                    , onChange = PlotterControl.Model.ChangePreset
                    }
                , paragraph theme
                    [ fontSize 14 ]
                    [ text "Set depth, pressure, offset, velocity on plotter."
                    ]
                ]
            )
        , case Ok () of
            Ok _ ->
                form
                    (el (theme.label ++ [ width fill, fontAlignRight ]) (text "Marker loading:"))
                    (inputRadio [ spacing 8 ]
                        { label = labelHidden "Marker loading:"
                        , options =
                            [ inputOption PlotterControl.Settings.LoadAllAtOnce (text "All at Once")
                            , inputOption PlotterControl.Settings.LoadSequentially (text "Sequentially")
                            ]
                        , selected = Just model.settings.markerLoading
                        , onChange = PlotterControl.Model.ChangeMarkerLoading
                        }
                    )

            Err _ ->
                none
        , inputNumber
            { label = el (theme.label ++ [ width fill, fontAlignRight ]) (text "Copies:")
            , value =
                el [ fontVariant fontTabularNumbers ]
                    (text
                        (model.settings.copies
                            |> (\(PlotterControl.Settings.Copies v) -> v)
                            |> String.fromInt
                        )
                    )
            , onChange = PlotterControl.Settings.Copies >> PlotterControl.Model.PlusCopies
            }
        , inputNumber
            { label = el (theme.label ++ [ width fill, fontAlignRight ]) (text "Distance between copies:")
            , value =
                el [ fontVariant fontTabularNumbers ]
                    (text (mmToString model.settings.copyDistance))
            , onChange = toFloat >> Length.millimeters >> PlotterControl.Model.PlusCopyDistance
            }
        , form
            none
            (column [ spacing 8 ]
                [ case model.file of
                    Ok _ ->
                        button theme
                            [ paddingXY 16 12 ]
                            { label = text "Send File"
                            , onPress = Just PlotterControl.Model.SendFile
                            }

                    Err _ ->
                        none
                , case model.serialPort of
                    Ok _ ->
                        text "Data sent."

                    Err b ->
                        case b of
                            PlotterControl.Model.Ready ->
                                none

                            PlotterControl.Model.Sending ->
                                text "Sending..."

                            PlotterControl.Model.SerialPortError c ->
                                case c of
                                    PlotterControl.SerialPort.SerialPortError d ->
                                        case d of
                                            SerialPort.NotSupported ->
                                                text "Your browser is not supported."

                                            SerialPort.Busy ->
                                                text "Device is busy."

                                            SerialPort.Disconnected ->
                                                text "Device has been disconnected."

                                            SerialPort.JavaScriptError _ ->
                                                text "Internal error."

                                    PlotterControl.SerialPort.WakeLockError d ->
                                        case d of
                                            WakeLock.JavaScriptError _ ->
                                                text "Internal error."
                ]
            )
        ]



--


inputNumber : { label : Element msg, value : Element msg, onChange : Int -> msg } -> Element msg
inputNumber config =
    form
        config.label
        (row [ spacing 8 ]
            [ linkWithOnPress theme
                []
                { label = FeatherIcons.minus |> FeatherIcons.withSize 20 |> FeatherIcons.toHtml [] |> html
                , onPress = config.onChange -1 |> Just
                }
            , config.value
            , linkWithOnPress theme
                []
                { label = FeatherIcons.plus |> FeatherIcons.withSize 20 |> FeatherIcons.toHtml [] |> html
                , onPress = config.onChange 1 |> Just
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
            |> Json.Decode.map (\v -> ( msg v, True ))
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
        |> (\v -> v / 10)
        |> String.fromFloat
        |> (\v -> v ++ " mm")

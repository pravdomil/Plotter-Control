module App.PlotterControl.PlotterControl_ exposing (..)

import App.App.App exposing (..)
import App.PlotterControl.PlotterControl exposing (..)
import Browser exposing (Document)
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick, onInput)
import Styles.C as C
import Task
import Utils.Interop as Interop exposing (Status(..))


{-| -}
init : PlotterControl
init =
    { status = Ready
    , console = ""
    }


{-| -}
update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        NothingHappened ->
            ( model, Cmd.none )

        --
        GotJavaScriptMessage a ->
            case a of
                Just b ->
                    case b of
                        GotError c ->
                            ( { model | errors = c :: model.errors }, Cmd.none )

                        SerialPortUpdated c ->
                            ( { model | port_ = c }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        --
        ConnectToPlotter ->
            ( model
            , sendElmMessage
                (ConnectSerialPort
                    (SerialPortFilter 0x0403 0x6001)
                    (SerialOptions baudRate)
                )
            )

        --
        LoadFile ->
            ( model
            , Select.file [] (GotFile >> config.sendMsg)
            )

        GotFile a ->
            ( model
            , a |> File.toString |> Task.perform (GotFileWithContent a >> config.sendMsg)
            )

        GotFileWithContent a b ->
            ( { model | file = Just ( a, b ) }
            , Cmd.none
            )

        --
        SendFile ->
            case model.file of
                Just ( _, data ) ->
                    sendData config model (data ++ (Recut |> sendCommand |> String.repeat 100))

                _ ->
                    ( model, Cmd.none )

        SendData data ->
            sendData config model data



--


{-| -}
sendData : PlotterControl -> String -> ( PlotterControl, Cmd msg )
sendData model data =
    case model.port_ of
        Ready port_ ->
            ( model, sendElmMessage (SendToSerialPort port_ data) )

        _ ->
            ( model, Cmd.none )



--


{-| -}
subscriptions : Model -> Sub Msg
subscriptions _ =
    Interop.statusSubscription (GotStatus >> PlotterControlMsg)



--


{-| -}
view : PlotterControl -> Document msg
view model =
    let
        col : number -> number
        col i =
            2 * (i + 1) + i * 22
    in
    { title = S.pageTitle
    , body =
        [ h3 (float [ Left (col 0), Top 1.5, Size 22 3 ])
            [ text S.pageTitle ]
        , div (float [ Left (col 0), Top 5, Size 22 40 ])
            [ viewControls config model
            ]
        , div (float [ Left (col 1), Top 5, Size 22 40 ])
            [ viewPlotterSettings config model
            , viewMarkerSettings config model
            ]
        , div (float [ Left (col 2), Top 5, Size 22 40 ])
            []
        , div
            (float [ Left 1, Bottom 1 ] ++ [ C.small, C.textDanger ])
            (model.errors |> List.map (\v -> div [] [ text v ]))
        ]
    }


{-| -}
viewControls : PlotterControl -> Html msg
viewControls model =
    div []
        [ p []
            [ case model.port_ of
                Idle ->
                    button [ C.btn, C.btnPrimary, onClick (ConnectToPlotter |> config.sendMsg) ]
                        [ text S.connectToPlotter
                        ]

                Connecting ->
                    button [ C.btn, C.btnPrimary, disabled True ]
                        [ text S.connectingToPlotter
                        ]

                Ready _ ->
                    button
                        [ C.btn, C.btnSuccess, disabled True ]
                        [ text S.connectedButtonLabel ]

                Busy ->
                    button
                        [ C.btn, C.btnDanger, disabled True ]
                        [ text S.sendingData
                        ]
            ]
        , p []
            [ button
                [ C.btn, C.btnPrimary, onClick (LoadFile |> config.sendMsg) ]
                [ text S.loadFile
                ]
            ]
        , p []
            [ button
                [ C.btn
                , C.btnDanger
                , onClick (SendFile |> config.sendMsg)
                , disabled ((model.file |> maybeToBool |> not) || (model.port_ |> portStatusToBool |> not))
                ]
                [ text S.cut
                , small []
                    [ text
                        (model.file
                            |> Maybe.map (\( v, _ ) -> " \"" ++ File.name v ++ "\"")
                            |> Maybe.withDefault ""
                        )
                    ]
                ]
            ]
        , p []
            [ button
                [ C.btn
                , C.btnDanger
                , onClickSend config Recut
                , disabled (model.port_ |> portStatusToBool |> not)
                ]
                [ text "Recut"
                ]
            ]
        , p []
            [ small []
                [ text ("Make sure to set baud rate to " ++ fromInt baudRate ++ " bits/s.")
                ]
            ]
        , div [ C.mb5 ] []
        ]


{-| -}
viewPlotterSettings : PlotterControl -> Html msg
viewPlotterSettings model =
    fieldset [ disabled (portStatusToBool model.port_ |> not) ]
        [ p []
            [ b []
                [ text "Plotter Settings"
                ]
            ]
        , viewFormLabelAndInput (text "Knife Pressure:")
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputSend config (\v -> [ Set ("KNIFE_PRESSURE=" ++ fromInt v) ])
                    ]
                    []
                , span [ C.inputGroupText ] [ text "g" ]
                ]
            )
        , viewFormLabelAndInput (text "Velocity:")
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputSend config (\v -> [ Set ("VELOCITY=" ++ fromInt v) ])
                    ]
                    []
                , span [ C.inputGroupText ] [ text "mm/s" ]
                ]
            )
        , viewFormLabelAndInput (text "Recut offset:")
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputSend config (\v -> [ Set ("RECUT_OFFSET=" ++ fromInt v) ])
                    ]
                    []
                , span [ C.inputGroupText ] [ text "mm" ]
                ]
            )
        , div [ C.mb5 ] []
        ]


{-| -}
viewMarkerSettings : PlotterControl -> Html msg
viewMarkerSettings model =
    fieldset [ disabled (portStatusToBool model.port_ |> not) ]
        [ p []
            [ b []
                [ text "Marker Settings"
                ]
            ]
        , viewFormLabelAndInput (text "Size:")
            (div
                [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputSend config
                        (\v ->
                            [ Set ("MARKER_X_SIZE=" ++ fromInt (v * 40))
                            , Set ("MARKER_Y_SIZE=" ++ fromInt (v * 40))
                            ]
                        )
                    ]
                    []
                , span [ C.inputGroupText ] [ text "mm" ]
                ]
            )
        , viewFormLabelAndInput (text "X Distance:")
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputSend config (\v -> [ Set ("MARKER_X_DIS=" ++ fromInt (v * 4)) ])
                    ]
                    []
                , span [ C.inputGroupText ] [ text "mm/10" ]
                ]
            )
        , viewFormLabelAndInput (text "Y Distance:")
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputSend config (\v -> [ Set ("MARKER_Y_DIS=" ++ fromInt (v * 4)) ])
                    ]
                    []
                , span [ C.inputGroupText ] [ text "mm/10" ]
                ]
            )
        , viewFormLabelAndInput (text "Markers on X Axis:")
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputSend config (\v -> [ Set ("MARKER_X_N=" ++ fromInt v) ])
                    ]
                    []
                ]
            )
        , viewFormLabelAndInput (text "Sensitivity:")
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputSend config (\v -> [ Set ("OPOS_LEVEL=" ++ fromInt v) ])
                    ]
                    []
                ]
            )
        , div [ C.m3 ] []
        , viewFormLabelAndInput (text "")
            (button
                [ C.btn, C.btnPrimary, onClickSend config LoadMarkers ]
                [ text S.loadMarkers
                ]
            )
        , div [ C.mb5 ] []
        ]


{-| -}
viewOposCalibration : PlotterControl -> Html msg
viewOposCalibration _ =
    div []
        [ p []
            [ b []
                [ text "OPOS Calibration"
                ]
            ]
        , viewFormLabelAndInput (text S.xOffset)
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputSend config (\v -> [ SetSys ("OPOS_xoffset=" ++ fromInt v) ])
                    ]
                    []
                , span [ C.inputGroupText ] [ text "mm / 80" ]
                ]
            )
        , viewFormLabelAndInput (text S.yOffset)
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputSend config (\v -> [ SetSys ("OPOS_yoffset=" ++ fromInt v) ])
                    ]
                    []
                , span [ C.inputGroupText ] [ text "mm / 80" ]
                ]
            )
        , div [ C.mb5 ] []
        ]



--


{-| Send command on click.
-}
onClickSend : Command -> Attribute msg
onClickSend a =
    onClick (sendCommand a |> SendData |> config.sendMsg)


{-| Send commands on input.
-}
onInputSend : (Int -> List Command) -> Attribute msg
onInputSend toCommands =
    onInput
        (\v ->
            v
                |> String.toInt
                |> Maybe.map (toCommands >> sendCommands >> SendData)
                |> Maybe.withDefault NothingHappened
                |> config.sendMsg
        )


{-| To show form label and input.
-}
viewFormLabelAndInput : Html a -> Html a -> Html a
viewFormLabelAndInput a b =
    div [ C.row, C.g2, C.mb2 ]
        [ div [ C.col, C.dFlex, C.alignItemsCenter ] [ a ]
        , div [ C.col ] [ b ]
        ]

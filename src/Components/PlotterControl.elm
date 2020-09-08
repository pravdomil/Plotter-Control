module Components.PlotterControl exposing (Config, Model, Msg, init, publicMsg, subscriptions, update, view)

import Browser exposing (Document)
import File exposing (File)
import File.Select as Select
import Html exposing (Attribute, Html, a, b, button, div, fieldset, h3, input, p, small, span, text)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Ports exposing (javaScriptMessageSubscription, sendElmMessage)
import String exposing (fromInt)
import Styles.C as C
import Task
import Types.Messages exposing (ElmMessage(..), JavaScriptMessage(..), JsRefSerialPort, SerialOptions, SerialPortFilter, SerialPortStatus(..), portStatusToBool)
import Utils.Layout exposing (Constrain(..), float)
import Utils.S as S
import Utils.Utils exposing (maybeToBool)


{-| To define what can happen.
-}
type Msg
    = --
      GotJavaScriptMessage (Maybe JavaScriptMessage)
      --
    | ConnectToPlotter
      --
    | LoadFile
    | GotFile File
    | GotFileWithContent File String
      --
    | PlotFile
    | PlotData String


{-| To make some messages available outside this module.
-}
publicMsg =
    {}


{-| To define things we keep.
-}
type alias Model =
    { errors : List String
    , port_ : SerialPortStatus
    , file : Maybe ( File, String )
    }


{-| To define what things we need.
-}
type alias Config msg =
    { sendMsg : Msg -> msg
    }


{-| To hardcore serial port baud rate.
-}
baudRate =
    57600


{-| To init our component.
-}
init : Config msg -> Decode.Value -> ( Model, Cmd msg )
init _ _ =
    ( { errors = []
      , port_ = Idle
      , file = Nothing
      }
    , Cmd.none
    )


{-| To update our component.
-}
update : Config msg -> Msg -> Model -> ( Model, Cmd msg )
update config msg model =
    case msg of
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
        PlotFile ->
            case model.file of
                Just ( _, data ) ->
                    plotData config model data

                _ ->
                    ( model, Cmd.none )

        PlotData data ->
            plotData config model data


{-| To plot data.
-}
plotData : Config msg -> Model -> String -> ( Model, Cmd msg )
plotData _ model data =
    case model.port_ of
        Ready port_ ->
            ( model, sendElmMessage (SendToSerialPort port_ data) )

        _ ->
            ( model, Cmd.none )


{-| To handle subscriptions.
-}
subscriptions : Config msg -> Model -> Sub msg
subscriptions config _ =
    javaScriptMessageSubscription (GotJavaScriptMessage >> config.sendMsg)


{-| To show interface.
-}
view : Config msg -> Model -> Document msg
view config model =
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
            [ viewConfiguration config model
            ]
        , div (float [ Left (col 2), Top 5, Size 22 40 ])
            [ viewSystemConfiguration config model
            ]
        , div
            (float [ Left 1, Bottom 1 ] ++ [ C.small, C.textDanger ])
            (model.errors |> List.map (\v -> div [] [ text v ]))
        ]
    }


{-| To show controls.
-}
viewControls : Config msg -> Model -> Html msg
viewControls config model =
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
                , onClick (PlotFile |> config.sendMsg)
                , disabled ((model.file |> maybeToBool |> not) || (model.port_ |> portStatusToBool |> not))
                ]
                [ text
                    (S.plot
                        ++ (model.file
                                |> Maybe.map Tuple.first
                                |> Maybe.map File.name
                                |> Maybe.map ((++) " ")
                                |> Maybe.withDefault ""
                           )
                    )
                ]
            ]
        , p []
            [ small []
                [ text ("Make sure to set baud rate to " ++ fromInt baudRate ++ " bits/s.")
                ]
            ]
        , p []
            [ b []
                [ text "Plotter Settings"
                ]
            ]
        , fieldset [ disabled (portStatusToBool model.port_ |> not) ]
            [ viewFormLabelAndInput (text "Knife Pressure:")
                (div [ C.inputGroup ]
                    [ input
                        [ C.formControl
                        , onInputPlot config (\v -> "SET KNIFE_PRESSURE=" ++ fromInt v)
                        ]
                        []
                    , span [ C.inputGroupText ] [ text "g" ]
                    ]
                )
            ]
        ]


{-| Plot if input changed.
-}
onInputPlot : Config msg -> (Int -> String) -> Attribute msg
onInputPlot config fn =
    onInput
        (\v ->
            v
                |> String.toInt
                |> Maybe.map fn
                |> Maybe.map (\vv -> "\u{001B};@:\n" ++ vv ++ "\nEND\n")
                |> Maybe.withDefault ""
                |> Plot
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


{-| -}
viewConfiguration : Config msg -> Model -> Html msg
viewConfiguration config model =
    let
        onClickPlot : String -> Attribute msg
        onClickPlot a =
            onClick
                (("\u{001B};@:\n" ++ a ++ "\nEND\n")
                    |> Plot
                    |> config.sendMsg
                )
    in
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
                    , onInputPlot config
                        (\v ->
                            [ "SET MARKER_X_SIZE=" ++ fromInt (v * 40)
                            , "SET MARKER_Y_SIZE=" ++ fromInt (v * 40)
                            ]
                                |> String.join "\n"
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
                    , onInputPlot config (\v -> "SET MARKER_X_DIS=" ++ fromInt (v * 4))
                    ]
                    []
                , span [ C.inputGroupText ] [ text "mm/10" ]
                ]
            )
        , viewFormLabelAndInput (text "Y Distance:")
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputPlot config (\v -> "SET MARKER_Y_DIS=" ++ fromInt (v * 4))
                    ]
                    []
                , span [ C.inputGroupText ] [ text "mm/10" ]
                ]
            )
        , viewFormLabelAndInput (text "Markers on X Axis:")
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputPlot config (\v -> "SET MARKER_X_N=" ++ fromInt v)
                    ]
                    []
                ]
            )
        , viewFormLabelAndInput (text "Sensitivity:")
            (div [ C.inputGroup ]
                [ input
                    [ C.formControl
                    , onInputPlot config (\v -> "SET OPOS_LEVEL=" ++ fromInt v)
                    ]
                    []
                ]
            )
        , div [ C.m3 ] []
        , viewFormLabelAndInput (text "")
            (button
                [ C.btn, C.btnPrimary, onClickPlot "LOAD_MARKERS" ]
                [ text S.loadMarkers
                ]
            )
        , div [ C.m5 ] []
        , div [ C.dNone ]
            [ p []
                [ b []
                    [ text "OPOS Calibration"
                    ]
                ]
            , viewFormLabelAndInput (text S.xOffset)
                (div [ C.inputGroup ]
                    [ input
                        [ C.formControl
                        , onInputPlot config (\v -> "SETSYS OPOS_xoffset=" ++ fromInt v)
                        ]
                        []
                    , span [ C.inputGroupText ] [ text "mm / 80" ]
                    ]
                )
            , viewFormLabelAndInput (text S.yOffset)
                (div [ C.inputGroup ]
                    [ input
                        [ C.formControl
                        , onInputPlot config (\v -> "SETSYS OPOS_yoffset=" ++ fromInt v)
                        ]
                        []
                    , span [ C.inputGroupText ] [ text "mm / 80" ]
                    ]
                )
            ]
        ]


{-| -}
viewSystemConfiguration : Config msg -> Model -> Html msg
viewSystemConfiguration _ _ =
    div []
        [ text "" ]

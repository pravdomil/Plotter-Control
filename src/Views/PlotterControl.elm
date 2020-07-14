module Views.PlotterControl exposing (Config, Model, Msg, init, publicMsg, subscriptions, update, view)

import Browser exposing (Document)
import File exposing (File)
import File.Select as Select
import Html exposing (Attribute, Html, a, button, div, h3, p, text)
import Html.Attributes exposing (class, disabled)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Languages.L as L
import Ports exposing (javaScriptMessageSubscription, sendElmMessage)
import String exposing (join)
import Task
import Types.Messages exposing (ElmMessage(..), JavaScriptMessage(..), JsRefSerialPort, SerialOptions, SerialPortFilter, SerialPortStatus(..), portStatusToBool)
import Utils.Rectangle exposing (PositionX(..), PositionY(..), absolute)


{-| To define what can happen.
-}
type Msg
    = -- Outside World
      GotJavaScriptMessage (Maybe JavaScriptMessage)
      -- UI
    | ConnectToPlotter
    | Plot String
    | PlotFile
    | GotPlotFile File


{-| To make some messages available outside this module.
-}
publicMsg =
    {}


{-| To define things we keep.
-}
type alias Model =
    { errors : List String
    , port_ : SerialPortStatus
    }


{-| To define what things we need.
-}
type alias Config msg =
    { sendMsg : Msg -> msg
    }


{-| To init our view.
-}
init : Config msg -> Decode.Value -> ( Model, Cmd msg )
init _ _ =
    ( { errors = []
      , port_ = Idle
      }
    , Cmd.none
    )


{-| To update our view.
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

        ConnectToPlotter ->
            ( model
            , sendElmMessage
                (ConnectSerialPort
                    (SerialPortFilter 0x0403 0x6001)
                    (SerialOptions 9600)
                )
            )

        Plot data ->
            case model.port_ of
                Ready a ->
                    ( model
                    , sendElmMessage (SendToSerialPort a data)
                    )

                _ ->
                    ( model, Cmd.none )

        PlotFile ->
            ( model
            , Select.file [] (GotPlotFile >> config.sendMsg)
            )

        GotPlotFile a ->
            ( model
            , a |> File.toString |> Task.perform (Plot >> config.sendMsg)
            )


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
        col i =
            2 * (i + 1) + i * w

        w =
            22
    in
    { title = L.pageTitle
    , body =
        [ h3 (absolute ( Left (col 0) w, Top 1.5 3 ))
            [ text L.pageTitle ]
        , div (absolute ( Left (col 0) w, Top 5 40 ))
            [ viewControls config model
            ]
        , div (absolute ( Left (col 1) w, Top 5 40 ))
            [ viewConfiguration config model
            ]
        , div (absolute ( Left (col 2) w, Top 5 40 ))
            [ viewSystemConfiguration config model
            ]
        , div
            (absolute ( Left 1 0, Bottom 1 0 ) ++ [ class "small text-danger" ])
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
                    button [ class "btn btn-primary", onClick (ConnectToPlotter |> config.sendMsg) ]
                        [ text L.connectToPlotter
                        ]

                Connecting ->
                    button [ class "btn btn-primary", disabled True ]
                        [ text L.connectingToPlotter
                        ]

                Ready _ ->
                    button
                        [ class "btn btn-success", disabled True ]
                        [ text L.connectedButtonLabel ]

                Busy ->
                    button
                        [ class "btn btn-danger", disabled True ]
                        [ text L.sendingData
                        ]
            ]
        , p []
            [ button
                [ class "btn btn-primary btn-sm"
                , disabled (portStatusToBool model.port_ |> not)
                , onClick (PlotFile |> config.sendMsg)
                ]
                [ text L.plotFile
                ]
            ]
        , p []
            [ button
                [ class "btn btn-primary btn-sm"
                , disabled (portStatusToBool model.port_ |> not)
                , onClick ("\u{001B};@:\nLOAD_MARKERS\nEND\n" |> Plot |> config.sendMsg)
                ]
                [ text L.loadMarkers
                ]
            ]
        , p []
            [ button
                [ class "btn btn-primary btn-sm"
                , disabled (portStatusToBool model.port_ |> not)
                , onClick ("\u{001B};@:\nRECUT\nEND\n" |> Plot |> config.sendMsg)
                ]
                [ text L.recut
                ]
            ]
        ]


{-| -}
viewConfiguration : Config msg -> Model -> Html msg
viewConfiguration _ _ =
    div []
        [ text "" ]


{-| -}
viewSystemConfiguration : Config msg -> Model -> Html msg
viewSystemConfiguration _ _ =
    div []
        [ text "" ]

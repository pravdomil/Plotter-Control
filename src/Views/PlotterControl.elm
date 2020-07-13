module Views.PlotterControl exposing (Config, Model, Msg, init, publicMsg, subscriptions, update, view)

import Browser exposing (Document)
import File exposing (File)
import File.Select as Select
import Html exposing (Attribute, Html, a, button, div, h3, input, label, li, ol, p, small, span, text)
import Html.Attributes exposing (checked, class, disabled, type_)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Languages.L as L
import Ports exposing (javaScriptMessageSubscription, sendElmMessage)
import String exposing (join)
import Task
import Types.Messages exposing (ElmMessage(..), JavaScriptMessage(..), JsRefSerialPort, PortStatus(..), SerialOptions, SerialPortFilter)
import Utils.Command exposing (Command(..), commandsToString, offsetBy)
import Utils.Rectangle exposing (PositionX(..), PositionY(..), absolute)
import Utils.RegistrationMark exposing (horizontalRegistrationMark, verticalRegistrationMark)


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
    | ChangeOrientation Orientation


{-| To make some messages available outside this module.
-}
publicMsg =
    {}


{-| To define things we keep.
-}
type alias Model =
    { errors : List String
    , port_ : PortStatus
    , orientation : Maybe Orientation
    }


type Orientation
    = Front
    | Rear


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
      , orientation = Nothing
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

        ChangeOrientation a ->
            ( { model | orientation = Just a }, Cmd.none )


{-| To handle subscriptions.
-}
subscriptions : Config msg -> Model -> Sub msg
subscriptions config _ =
    javaScriptMessageSubscription (GotJavaScriptMessage >> config.sendMsg)


{-| To show interface.
-}
view : Config msg -> Model -> Document msg
view config model =
    { title = L.pageTitle
    , body =
        [ h3 (absolute ( Left 2 0, Top 1.5 0 ))
            [ text L.pageTitle ]
        , div (absolute ( Left 2 0, Top 5 0 ))
            [ viewControlInterface config model ]
        , div
            (absolute ( Left 1 0, Bottom 1 0 ) ++ [ class "small text-danger" ])
            (model.errors |> List.map (\v -> div [] [ text v ]))
        ]
    }


{-| To show control interface.
-}
viewControlInterface : Config msg -> Model -> Html msg
viewControlInterface config model =
    div []
        [ div (absolute ( Left 0 19, Top 0 0 ))
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
            , div []
                [ div [] [ text "Orientation" ]
                , div [ class "d-flex" ]
                    [ label []
                        [ input
                            [ type_ "radio"
                            , checked (model.orientation == Just Front)
                            , onInput (\_ -> ChangeOrientation Front |> config.sendMsg)
                            ]
                            []
                        , span [ class "align-text-bottom" ] [ text " Front" ]
                        ]
                    ]
                , div [ class "d-flex" ]
                    [ label []
                        [ input
                            [ type_ "radio"
                            , checked (model.orientation == Just Rear)
                            , onInput (\_ -> ChangeOrientation Rear |> config.sendMsg)
                            ]
                            []
                        , span [ class "align-text-bottom" ] [ text " Rear" ]
                        ]
                    ]
                ]
            , p [] [ small [] [ text L.plotterNotes ] ]
            ]
        , div (absolute ( Left 22 40, Top -4.5 0 ))
            [ case model.orientation of
                Just a ->
                    viewControlInterface2 config model a

                Nothing ->
                    text ""
            ]
        ]


{-| To view registration marks.
-}
viewControlInterface2 : Config msg -> Model -> Orientation -> Html msg
viewControlInterface2 config _ orientation =
    let
        registrationMarkOffset =
            case orientation of
                Front ->
                    2.5

                Rear ->
                    0.5

        horizontal =
            horizontalRegistrationMark |> List.map (offsetBy ( 0, registrationMarkOffset ))

        vertical =
            verticalRegistrationMark |> List.map (offsetBy ( registrationMarkOffset, 0 ))

        plot a offset ( moveToX, moveToY ) =
            a
                |> List.map (offsetBy offset)
                |> (\v -> v ++ [ LineStart moveToX moveToY, LineEnd ])
                |> onClickPlot

        onClickPlot : List Command -> Attribute msg
        onClickPlot a =
            a |> commandsToString |> Plot |> config.sendMsg |> onClick
    in
    div []
        [ p [ class "mb-0" ] [ text "Axis A - Zeroing" ]
        , ol []
            [ li []
                [ text "Set zero by guesswork."
                ]
            , li []
                [ button [ class "btn btn-sm btn-primary mb-1", plot horizontal ( 0, 0 ) ( 0, 200 ) ]
                    [ text "Cut Registration Mark"
                    ]
                ]
            , li []
                [ text "Read compensation and "
                , button [ class "btn btn-sm btn-primary mb-1", onClickPlot [ LineStart 0 0, LineEnd ] ]
                    [ text "Go to Zero"
                    ]
                , text "."
                ]
            , li []
                [ text "Set zero by reading correction from registration mark."
                ]
            , li []
                [ button [ class "btn btn-sm btn-primary mb-1", plot horizontal ( 0, 12 ) ( 0, 200 ) ]
                    [ text "Cut Registration Mark to Verify Correction"
                    ]
                ]
            ]
        , p [ class "mb-0" ] [ text "Axis A - Distance Compensation" ]
        , ol []
            [ li []
                [ button [ class "btn btn-sm btn-primary mb-1", plot horizontal ( 0, 900 + 12 ) ( 0, 700 ) ]
                    [ text "Cut Registration Mark"
                    ]
                ]
            , li []
                [ text "Read compensation and "
                , button [ class "btn btn-sm btn-primary mb-1", onClickPlot [ LineStart 0 0, LineEnd ] ]
                    [ text "Go to Zero"
                    ]
                , text "."
                ]
            , li []
                [ text "Press \"Sheet Set\" and \"Function\" and set distance compensation." ]
            , li []
                [ text "Load leaf again and set zero by guesswork." ]
            , li []
                [ button [ class "btn btn-sm btn-primary", plot horizontal ( 0, 900 ) ( 0, 700 ) ]
                    [ text "Cut Registration Mark to Verify Correction"
                    ]
                ]
            ]
        , p [ class "mb-0" ] [ text "Axis B - Zeroing" ]
        , ol []
            [ li []
                [ button [ class "btn btn-sm btn-primary mb-1", plot vertical ( 0, 0 ) ( 0, 200 ) ]
                    [ text "Cut Registration Mark"
                    ]
                ]
            , li []
                [ text "Read compensation and "
                , button [ class "btn btn-sm btn-primary mb-1", onClickPlot [ LineStart 0 0, LineEnd ] ]
                    [ text "Go to Zero"
                    ]
                , text "."
                ]
            , li []
                [ text "Set zero by reading correction from registration mark." ]
            , li []
                [ button [ class "btn btn-sm btn-primary mb-1", plot vertical ( 0, 12 ) ( 0, 200 ) ]
                    [ text "Cut Registration Mark to Verify Correction"
                    ]
                ]
            ]
        , p [ class "mb-0" ] [ text "Axis Alignment" ]
        , ol []
            [ li []
                [ button [ class "btn btn-sm btn-primary mb-1", plot vertical ( 0, 900 + 12 ) ( 0, 700 ) ]
                    [ text "Cut Registration Mark"
                    ]
                ]
            , li []
                [ text "Read compensation and "
                , button [ class "btn btn-sm btn-primary mb-1", onClickPlot [ LineStart 0 (900 + 12), LineEnd ] ]
                    [ text "Go Back to Registration Mark"
                    ]
                , text "."
                ]
            , li []
                [ text "Press any arrow key and \"Function\" and set axis alignment." ]
            , li []
                [ button [ class "btn btn-sm btn-primary mb-1", plot vertical ( 0, 900 ) ( 0, 700 ) ]
                    [ text "Cut Registration Mark to Verify Correction"
                    ]
                ]
            ]
        , p [ class "mb-0" ] [ text "Finish" ]
        , ol []
            [ li []
                [ button
                    [ class "btn btn-sm btn-primary mb-1"
                    , onClickPlot
                        ((horizontal ++ vertical |> List.map (offsetBy ( 0, 100 )))
                            ++ (horizontal ++ vertical |> List.map (offsetBy ( 0, 800 )))
                            ++ [ LineStart 0 500, LineEnd ]
                        )
                    ]
                    [ text "Verify Calibration 1"
                    ]
                , text " "
                , button
                    [ class "btn btn-sm btn-primary mb-1"
                    , onClickPlot
                        ((horizontal ++ vertical |> List.map (offsetBy ( 0, 100 + 12 )))
                            ++ (horizontal ++ vertical |> List.map (offsetBy ( 0, 800 + 12 )))
                            ++ [ LineStart 0 500, LineEnd ]
                        )
                    ]
                    [ text "Verify Calibration 2"
                    ]
                , text " "
                , button
                    [ class "btn btn-sm btn-primary mb-1"
                    , onClickPlot
                        ((horizontal ++ vertical |> List.map (offsetBy ( 0, 100 + 12 + 12 )))
                            ++ (horizontal ++ vertical |> List.map (offsetBy ( 0, 800 + 12 + 12 )))
                            ++ [ LineStart 0 500, LineEnd ]
                        )
                    ]
                    [ text "Verify Calibration 3"
                    ]
                ]
            , li []
                [ button
                    [ class "btn btn-sm btn-primary mb-1"
                    , onClick ((testCut ++ ([ LineStart 0 200, LineEnd ] |> commandsToString)) |> Plot |> config.sendMsg)
                    ]
                    [ text "Do Test Cut"
                    ]
                ]
            , li []
                [ button [ class "btn btn-sm btn-primary mb-1", onClick (PlotFile |> config.sendMsg) ]
                    [ text "Plot File"
                    ]
                ]
            ]
        ]


testCut =
    [ "IN"
    , "IP0,0,1,1"
    , "PU2164.00,424.00"
    , "PD2164.00,64.01"
    , "PD2167.05,45.04"
    , "PD2175.57,28.57"
    , "PD2188.56,15.58"
    , "PD2205.03,7.06"
    , "PD2224.00,4.01"
    , "PD2303.99,4.01"
    , "PD2303.99,84.00"
    , "PD2306.72,94.10"
    , "PD2313.90,101.27"
    , "PD2323.99,104.00"
    , "PD2483.99,104.00"
    , "PD2494.08,101.27"
    , "PD2501.26,94.10"
    , "PD2503.99,84.00"
    , "PD2503.99,4.01"
    , "PD2584.00,4.01"
    , "PD2602.96,7.06"
    , "PD2619.43,15.58"
    , "PD2632.42,28.57"
    , "PD2640.94,45.04"
    , "PD2644.00,64.01"
    , "PD2644.00,424.00"
    , "PD2640.94,442.96"
    , "PD2632.42,459.43"
    , "PD2619.43,472.41"
    , "PD2602.96,480.93"
    , "PD2584.00,484.00"
    , "PD2224.00,484.00"
    , "PD2205.03,480.93"
    , "PD2188.57,472.41"
    , "PD2175.58,459.42"
    , "PD2167.07,442.95"
    , "PD2164.01,424.00"
    , "PD2164.00,424.00"
    , "PU"
    ]
        |> join ";"

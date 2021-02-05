module App.PlotterControl.PlotterControl_ exposing (..)

import App.App.App exposing (..)
import App.PlotterControl.Filename as Filename exposing (Filename)
import App.PlotterControl.PlotterControl exposing (..)
import Dict exposing (Dict)
import File exposing (File)
import File.Select
import Html exposing (..)
import Html.Attributes exposing (autofocus, style, value)
import Html.Events exposing (onInput, onSubmit)
import Styles.C as C
import Task
import Utils.HpGl as HpGl exposing (HpGl)
import Utils.Interop as Interop exposing (Status(..), sendData)
import Utils.SummaCommand as SummaCommand
import Utils.Translation as Translation exposing (..)
import View.Layout exposing (..)


{-| -}
init : PlotterControl
init =
    { console = ""
    , status = Ready
    , file = Nothing
    }



--


{-| -}
type alias Command msg =
    { name : String
    , description : String
    , msg : msg
    }


{-| -}
commands : Dict String (Command Msg)
commands =
    let
        sensitivity : List (Command Msg)
        sensitivity =
            List.range 1 60
                |> List.map
                    (\v ->
                        Command
                            ("s" ++ String.fromInt v)
                            (t (A_Raw ("OPOS sensitivity " ++ String.fromInt v ++ ".")))
                            (SetSensitivity v |> PlotterControlMsg)
                    )
    in
    [ Command "l" (t (A_Raw "Load file.")) (LoadFile |> PlotterControlMsg)
    , Command "m" (t (A_Raw "Markers load.")) (LoadMarkers |> PlotterControlMsg)
    , Command "s" (t (A_Raw "OPOS sensitivity 30 (default).")) (SetSensitivity 30 |> PlotterControlMsg)
    , Command "p" (t (A_Raw "Plot file.")) (PlotFile |> PlotterControlMsg)
    ]
        ++ sensitivity
        |> List.map (\v -> ( v.name, v ))
        |> Dict.fromList


{-| -}
commandFromString : String -> Maybe (Command Msg)
commandFromString a =
    commands |> Dict.get (a |> String.toLower)



--


{-| -}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        { plotterControl } =
            model
    in
    (case msg of
        PlotterControlMsg a ->
            case a of
                ConsoleChanged b ->
                    ( { plotterControl | console = b }
                    , Cmd.none
                    )

                ConsoleSubmitted ->
                    consoleSubmitted model

                --
                LoadFile ->
                    ( plotterControl
                    , File.Select.file [] (GotFile >> PlotterControlMsg)
                    )

                LoadMarkers ->
                    ( plotterControl
                    , sendData (SummaCommand.LoadMarkers |> SummaCommand.toHpGl)
                    )

                SetSensitivity b ->
                    ( plotterControl
                    , sendData (SummaCommand.Set ("OPOS_LEVEL=" ++ String.fromInt b) |> SummaCommand.toHpGl)
                    )

                PlotFile ->
                    ( plotterControl
                    , plotFile model
                    )

                --
                GotStatus b ->
                    ( { plotterControl | status = b }
                    , Cmd.none
                    )

                GotFile b ->
                    ( plotterControl
                    , File.toString b |> Task.perform (GotFileContent b >> PlotterControlMsg)
                    )

                GotFileContent b c ->
                    ( { plotterControl
                        | file =
                            Just
                                { filename = Filename.fromString (File.name b)
                                , content = HpGl.fromString c
                                }
                      }
                    , Cmd.none
                    )
    )
        |> Tuple.mapFirst (\v -> { model | plotterControl = v })



--


{-| -}
consoleSubmitted : Model -> ( PlotterControl, Cmd Msg )
consoleSubmitted model =
    let
        ( status, cmd ) =
            case model.plotterControl.console |> commandFromString of
                Just a ->
                    ( model.plotterControl.status, Task.succeed () |> Task.perform (always a.msg) )

                Nothing ->
                    ( Error (t (A_Raw "Unknown command.")), Cmd.none )

        { plotterControl } =
            model
    in
    ( { plotterControl | console = "", status = status }
    , cmd
    )



--


{-| -}
plotFile : Model -> Cmd msg
plotFile model =
    case model.plotterControl.file of
        Just a ->
            case a.filename of
                Ok b ->
                    sendData (Filename.toHpGl b a.content)

                Err _ ->
                    sendData a.content

        Nothing ->
            Cmd.none



--


{-| -}
subscriptions : Model -> Sub Msg
subscriptions _ =
    Interop.statusSubscription (GotStatus >> PlotterControlMsg)



--


{-| -}
view : Model -> Layout Msg
view model =
    column ratio1
        []
        [ element (rem 4)
            []
            (h6 [ C.m3 ]
                [ text (t A_Title)
                ]
            )
        , row ratio1
            []
            [ column (ratio 1)
                [ C.borderEnd ]
                [ viewConsole model
                , viewCommands model
                ]
            , column (ratio 1.618)
                []
                [ viewStatus model
                , viewFile model
                ]
            ]
        ]


{-| -}
viewConsole : Model -> Layout Msg
viewConsole model =
    html (rem 6)
        []
        [ form [ C.mx3, onSubmit (ConsoleSubmitted |> PlotterControlMsg) ]
            [ h6 [ C.textMuted ]
                [ text (t (A_Raw "Console"))
                ]
            , input
                [ C.formControl
                , autofocus True
                , value model.plotterControl.console
                , onInput (ConsoleChanged >> PlotterControlMsg)
                ]
                []
            , div [ C.mt1, style "font-size" "14px" ]
                [ case model.plotterControl.console |> commandFromString of
                    Just a ->
                        text a.description

                    Nothing ->
                        text "\u{00A0}"
                ]
            ]
        ]


{-| -}
viewCommands : Model -> Layout Msg
viewCommands _ =
    html ratio1
        []
        [ div [ C.mx3, style "font-size" "14px" ]
            [ h6 [ C.textMuted ]
                [ text (t (A_Raw "Commands"))
                ]
            , table []
                [ tbody []
                    (commands
                        |> Dict.values
                        |> List.take 10
                        |> List.map viewCommand
                    )
                ]
            , p []
                [ text (t (A_Raw "Lower OPOS sensitivity means more sensitivity."))
                ]
            ]
        ]


{-| -}
viewCommand : Command Msg -> Html Msg
viewCommand a =
    tr []
        [ td [ C.fwBolder, C.p0, C.pe1 ]
            [ text (String.toUpper a.name)
            ]
        , td []
            [ text a.description
            ]
        ]


{-| -}
viewStatus : Model -> Layout Msg
viewStatus model =
    let
        textColor : Attribute msg
        textColor =
            case model.plotterControl.status of
                Ready ->
                    C.textPrimary

                Connecting ->
                    C.textPrimary

                Idle ->
                    C.textPrimary

                Busy ->
                    C.textDanger

                Error _ ->
                    C.textDanger
    in
    html (rem 6)
        []
        [ h6 [ C.mx3, C.textMuted ]
            [ text (t (A_Raw "Status"))
            ]
        , h3 [ C.mx3, textColor ]
            [ text (t (Translation.status model.plotterControl.status))
            ]
        ]


{-| -}
viewFile : Model -> Layout Msg
viewFile model =
    html ratio1
        []
        [ h6 [ C.mx3, C.textMuted ]
            [ text (t (A_Raw "File"))
            ]
        , case model.plotterControl.file of
            Just b ->
                case b.filename of
                    Ok c ->
                        viewFilename c

                    Err c ->
                        h3 [ C.mx3, C.textDanger ]
                            [ text (c |> String.replace "_" "_\u{200B}")
                            ]

            Nothing ->
                h3 [ C.mx3 ]
                    [ text (t (A_Raw "No file loaded."))
                    ]
        , p [ C.mx3, C.textMuted, style "font-size" "14px" ]
            [ text (t (A_Raw "Filename:"))
            , text " "
            , text Filename.format
            ]
        ]


{-| -}
viewFilename : Filename -> Html msg
viewFilename a =
    div [ C.mx3 ]
        [ h3 [ C.textPrimary ]
            [ text a.name
            ]
        , table [ style "font-size" "14px", C.mb2 ]
            [ tbody []
                [ tr []
                    [ td [ C.p0, C.pe1 ]
                        [ text (t (A_Raw "Width:"))
                        ]
                    , td []
                        [ text (String.fromFloat a.width)
                        , text "mm"
                        ]
                    ]
                , tr []
                    [ td [ C.p0, C.pe1 ]
                        [ text (t (A_Raw "Length:"))
                        ]
                    , td []
                        [ text (String.fromFloat a.length)
                        , text "mm"
                        , text " x "
                        , text (String.fromInt a.markers)
                        ]
                    ]
                , tr []
                    [ td [ C.p0, C.pe1 ]
                        [ text (t (A_Raw "Speed:"))
                        ]
                    , td []
                        [ text (String.fromInt a.speed)
                        , text "mm/s"
                        ]
                    ]
                , tr []
                    [ td [ C.p0, C.pe1 ]
                        [ text (t (A_Raw "Copies:"))
                        ]
                    , td []
                        [ text (String.fromInt a.copies)
                        , text "x"
                        ]
                    ]
                ]
            ]
        ]

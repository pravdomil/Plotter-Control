module App.PlotterControl.PlotterControl_ exposing (..)

import App.App.App exposing (..)
import App.PlotterControl.PlotterControl exposing (..)
import Dict exposing (Dict)
import File exposing (File)
import File.Select
import Html exposing (..)
import Html.Attributes exposing (autofocus, style, value)
import Html.Events exposing (onInput, onSubmit)
import Styles.C as C
import Task
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
            List.range 0 60
                |> List.map
                    (\v ->
                        Command
                            ("s" ++ String.fromInt v)
                            (t (A_Raw ("OPOS Sensitivity " ++ String.fromInt v ++ ".")))
                            (SetSensitivity v |> PlotterControlMsg)
                    )
    in
    [ Command "l" (t (A_Raw "Load File.")) (LoadFile |> PlotterControlMsg)
    , Command "m" (t (A_Raw "Markers Load.")) (LoadMarkers |> PlotterControlMsg)
    , Command "s" (t (A_Raw "OPOS Sensitivity 30 (default).")) (SetSensitivity 30 |> PlotterControlMsg)
    , Command "p" (t (A_Raw "Plot File.")) (PlotFile |> PlotterControlMsg)
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
                    , sendData (model.plotterControl.file |> Maybe.map Tuple.second |> Maybe.withDefault "")
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
                    ( { plotterControl | file = Just ( b, c ) }
                    , Cmd.none
                    )
    )
        |> Tuple.mapFirst (\v -> { model | plotterControl = v })


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
                [ viewStatus model, viewFile model ]
            ]
        ]


{-| -}
viewConsole : Model -> Layout Msg
viewConsole model =
    html (rem 6)
        []
        [ form [ C.mx3, onSubmit (ConsoleSubmitted |> PlotterControlMsg) ]
            [ h6 [ C.textMuted ] [ text (t (A_Raw "Console")) ]
            , p []
                [ input
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
        ]


{-| -}
viewCommands : Model -> Layout Msg
viewCommands _ =
    html ratio1
        []
        [ div [ C.mx3, style "font-size" "14px" ]
            [ h6 [ C.textMuted ] [ text (t (A_Raw "Commands")) ]
            , table []
                [ tbody []
                    (commands |> Dict.values |> List.take 10 |> List.map viewCommand)
                ]
            ]
        ]


{-| -}
viewCommand : Command Msg -> Html Msg
viewCommand a =
    tr []
        [ td [ C.fwBolder, C.pe1 ] [ text (String.toUpper a.name) ]
        , td [] [ text a.description ]
        ]


{-| -}
viewStatus : Model -> Layout Msg
viewStatus model =
    let
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
        [ h6 [ C.mx3, C.textMuted ] [ text (t (A_Raw "Status")) ]
        , h3 [ C.mx3, textColor ] [ text (t (Translation.status model.plotterControl.status)) ]
        ]


{-| -}
viewFile : Model -> Layout Msg
viewFile model =
    html ratio1
        []
        [ h6 [ C.mx3, C.textMuted ] [ text (t (A_Raw "File")) ]
        , h3 [ C.mx3 ]
            [ case model.plotterControl.file of
                Just ( b, _ ) ->
                    text (b |> File.name)

                Nothing ->
                    text (t (A_Raw "No file loaded."))
            ]
        ]

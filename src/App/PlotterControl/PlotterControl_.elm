module App.PlotterControl.PlotterControl_ exposing (..)

import App.App.App exposing (..)
import App.PlotterControl.PlotterControl exposing (..)
import Browser exposing (Document)
import File exposing (File)
import File.Select
import Html exposing (..)
import Html.Attributes exposing (autofocus, disabled, style, value)
import Html.Events exposing (onClick, onInput, onSubmit)
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
commands : List (Command Msg)
commands =
    let
        sensitivity : List (Command Msg)
        sensitivity =
            List.range 0 60
                |> List.map
                    (\v ->
                        Command
                            ("s" ++ String.fromInt v)
                            (t (A_Raw ("Set OPOS Sensitivity to " ++ String.fromInt v)))
                            (SetSensitivity v |> PlotterControlMsg)
                    )
    in
    [ Command "f" (t (A_Raw "File Load")) (LoadFile |> PlotterControlMsg)
    , Command "m" (t (A_Raw "Markers Load")) (LoadMarkers |> PlotterControlMsg)
    , Command "p" (t (A_Raw "Plot File")) (PlotFile |> PlotterControlMsg)
    ]
        ++ sensitivity



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
        { plotterControl } =
            model
    in
    ( { plotterControl | console = "" }
    , Cmd.none
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
        [ element (rem 5)
            []
            (h3 [ C.m3 ]
                [ text (t A_Title)
                ]
            )
        , row ratio1
            []
            [ column (ratio 1)
                [ C.borderEnd ]
                [ viewConsole model
                ]
            , column (ratio 1.618)
                []
                [ viewStatus model ]
            ]
        ]


{-| -}
viewConsole : Model -> Layout Msg
viewConsole model =
    html ratio1
        []
        [ form [ C.mx3, onSubmit (ConsoleSubmitted |> PlotterControlMsg) ]
            [ h6 [] [ text (t (A_Raw "Console")) ]
            , p []
                [ input
                    [ C.formControl
                    , autofocus True
                    , value model.plotterControl.console
                    , onInput (ConsoleChanged >> PlotterControlMsg)
                    ]
                    []
                ]
            ]
        , div [ C.mx3, style "font-size" "12px" ]
            [ h6 [] [ text (t (A_Raw "Commands")) ]
            , p [] (commands |> List.take 10 |> List.map viewCommand)
            ]
        ]


{-| -}
viewCommand : Command Msg -> Html Msg
viewCommand a =
    div []
        [ text a.name
        , text " - "
        , text a.description
        ]


{-| -}
viewStatus : Model -> Layout Msg
viewStatus model =
    html (rem 6)
        []
        [ h6 [ C.mx3 ] [ text (t (A_Raw "Status")) ]
        , h3 [ C.mx3 ] [ text (t (Translation.status model.plotterControl.status)) ]
        ]

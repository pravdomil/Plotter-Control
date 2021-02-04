module App.PlotterControl.PlotterControl_ exposing (..)

import App.App.App exposing (..)
import App.PlotterControl.PlotterControl exposing (..)
import Browser exposing (Document)
import File exposing (File)
import File.Select
import Html exposing (..)
import Html.Attributes exposing (autofocus, disabled, value)
import Html.Events exposing (onClick, onInput)
import Styles.C as C
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
commands : List ( String, String, Msg )
commands =
    let
        sensitivity : List ( String, String, Msg )
        sensitivity =
            List.range 0 60
                |> List.map
                    (\v ->
                        ( "s" ++ String.fromInt v
                        , t (A_Raw ("Set OPOS Sensitivity to " ++ String.fromInt v))
                        , SetSensitivity v |> PlotterControlMsg
                        )
                    )
    in
    [ ( "f", t (A_Raw "File Load"), LoadFile |> PlotterControlMsg )
    , ( "m", t (A_Raw "Markers Load"), LoadMarkers |> PlotterControlMsg )
    , ( "p", t (A_Raw "Plot File"), PlotFile |> PlotterControlMsg )
    ]
        ++ sensitivity



--


{-| -}
update : Msg -> Model -> ( Model, Cmd msg )
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

                --
                LoadFile ->
                    ( model
                    , File.Select.file [] (GotFile >> PlotterControlMsg)
                    )

                LoadMarkers ->
                    ( model
                    , sendData (SummaCommand.LoadMarkers |> SummaCommand.toHpGl)
                    )

                SetSensitivity b ->
                    ( model
                    , sendData (SummaCommand.Set ("OPOS_LEVEL=" ++ String.fromInt b) |> SummaCommand.toHpGl)
                    )

                PlotFile ->
                    ()

                --
                GotStatus b ->
                    ( { plotterControl | status = b }
                    , Cmd.none
                    )

                GotFile b ->
                    ( { plotterControl | file = Just b }
                    , Cmd.none
                    )
    )
        |> Tuple.mapFirst (\v -> { model | plotterControl = v })



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
    html (rem 6)
        []
        [ div [ C.mx3 ]
            [ h6 [] [ text (t (A_Raw "Console")) ]
            , input
                [ C.formControl
                , autofocus True
                , value model.plotterControl.console
                , onInput (ConsoleChanged >> PlotterControlMsg)
                ]
                []
            ]
        ]


{-| -}
viewStatus : Model -> Layout Msg
viewStatus model =
    html (rem 6)
        []
        [ h6 [ C.mx3 ] [ text (t (A_Raw "Status")) ]
        , h3 [ C.mx3 ] [ text (t (Translation.status model.plotterControl.status)) ]
        ]

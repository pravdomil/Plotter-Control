module App.PlotterControl.PlotterControl_ exposing (..)

import App.App.App exposing (..)
import App.PlotterControl.PlotterControl exposing (..)
import Browser exposing (Document)
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (autofocus, disabled, value)
import Html.Events exposing (onClick, onInput)
import Styles.C as C
import Utils.Interop as Interop exposing (Status(..))
import Utils.Translation exposing (..)
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

                SendData b ->
                    ( plotterControl
                    , Interop.sendData b
                    )

                GotStatus b ->
                    ( { plotterControl | status = b }
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
    row ratio1
        []
        [ column (ratio 1)
            [ C.borderEnd ]
            [ viewConsole model
            ]
        , column (ratio 1.618)
            []
            []
        ]


{-| -}
viewConsole : Model -> Layout Msg
viewConsole model =
    html ratio1
        []
        [ h3 [ C.m3 ]
            [ text (t A_Title)
            ]
        , div [ C.mx3 ]
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

module App.PlotterControl.PlotterControl_ exposing (..)

import App.App.App exposing (..)
import App.PlotterControl.PlotterControl exposing (..)
import Browser exposing (Document)
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick, onInput)
import Styles.C as C
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
view : PlotterControl -> Document msg
view model =

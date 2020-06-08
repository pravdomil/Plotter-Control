module Main exposing (main)

import Browser exposing (Document)
import Html exposing (Html, text)
import Json.Decode as Decode
import Languages.L as L
import Tuple exposing (mapFirst)
import Views.PlotterControl as PlotterControl


{-| To do something.
-}
main : Program Decode.Value Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


{-| To define what can happen.
-}
type Msg
    = PlotterControlMsg PlotterControl.Msg


{-| To create things needed for PlotterControl.
-}
plotterControlConfig : PlotterControl.Config Msg
plotterControlConfig =
    { sendMsg = PlotterControlMsg
    }


{-| To define things we keep.
-}
type alias Model =
    { plotterControl : PlotterControl.Model
    }


{-| To init our view.
-}
init : a -> ( Model, Cmd Msg )
init _ =
    let
        ( plotterControl, plotterControlCmd ) =
            PlotterControl.init plotterControlConfig
    in
    ( { plotterControl = plotterControl }, plotterControlCmd )


{-| To update our view.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlotterControlMsg subMsg ->
            PlotterControl.update plotterControlConfig subMsg model.plotterControl
                |> mapFirst (\v -> { model | plotterControl = v })


{-| To handle subscriptions.
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    PlotterControl.subscriptions plotterControlConfig model.plotterControl


{-| To show interface.
-}
view : Model -> Document Msg
view model =
    { title = L.pageTitle
    , body =
        [ PlotterControl.view plotterControlConfig model.plotterControl
        ]
    }

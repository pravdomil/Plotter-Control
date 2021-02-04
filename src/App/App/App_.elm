module App.App.App_ exposing (..)

import App.App.App exposing (..)
import App.PlotterControl.PlotterControl_ as PlotterControl_
import Browser exposing (Document)
import Html exposing (text)
import Json.Decode as Decode
import Utils.Translation exposing (Translation(..), t)
import Utils.Update as Update


{-| To init model.
-}
init : Decode.Value -> ( Model, Cmd Msg )
init _ =
    ( { plotterControl = PlotterControl_.init
      }
    , Cmd.none
    )


{-| To update model.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
        |> Update.andThen (PlotterControl_.update msg)


{-| To handle subscriptions.
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    PlotterControl_.subscriptions model


{-| To show interface.
-}
view : Model -> Document Msg
view model =
    { title = t A_Title
    , body =
        [ PlotterControl_.view model
        ]
    }

module App.App.App exposing (..)

import App.App.Types exposing (..)
import Browser exposing (Document)
import Html exposing (text)
import Json.Decode as Decode


{-| To init model.
-}
init : Decode.Value -> ( Model, Cmd Msg )
init _ =
    ( {}
    , Cmd.none
    )


{-| To update model.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NothingHappened ->
            ( model, Cmd.none )


{-| To handle subscriptions.
-}
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


{-| To show interface.
-}
view : Model -> Document Msg
view _ =
    { title = "Hello world!"
    , body =
        [ text "Hello world!"
        ]
    }

module App.App.App_ exposing (..)

import App.App.App exposing (..)
import App.Router.Router_ as Router_
import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Navigation
import Html exposing (text)
import Json.Decode as Decode
import Url exposing (Url)
import Utils.Update as Update


{-| To init model.
-}
init : Decode.Value -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ _ key =
    ( { router = Router_.init key
      }
    , Cmd.none
    )


{-| To update model.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
        |> Update.andThen (Router_.update msg)


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

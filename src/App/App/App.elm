module App.App.App exposing (..)

import App.Router.Router exposing (Router, RouterMsg)


{-| To define things we keep.
-}
type alias Model =
    { router : Router
    }


{-| To define what can happen.
-}
type Msg
    = RouterMsg RouterMsg

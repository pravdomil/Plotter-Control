module Main exposing (main)

import Browser
import Json.Decode as Decode
import Views.PlotterControl as PlotterControl


{-| To create things needed for App view.
-}
appConfig : PlotterControl.Config PlotterControl.Msg
appConfig =
    { sendMsg = identity
    }


{-| To create application with App view.
-}
main : Program Decode.Value PlotterControl.Model PlotterControl.Msg
main =
    Browser.document
        { init = PlotterControl.init appConfig
        , update = PlotterControl.update appConfig
        , subscriptions = PlotterControl.subscriptions appConfig
        , view = PlotterControl.view appConfig
        }

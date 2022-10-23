module PlotterControl.Main exposing (..)

import Browser
import Json.Decode
import PlotterControl.Model
import PlotterControl.Model.Update
import PlotterControl.Msg
import PlotterControl.View


main : Program Json.Decode.Value PlotterControl.Model.Model PlotterControl.Msg.Msg
main =
    Browser.document
        { init = PlotterControl.Model.Update.init
        , update = PlotterControl.Model.Update.update
        , subscriptions = PlotterControl.Model.Update.subscriptions
        , view = PlotterControl.View.view
        }

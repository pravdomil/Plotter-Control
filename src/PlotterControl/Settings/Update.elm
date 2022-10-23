module PlotterControl.Settings.Update exposing (..)

import Platform.Extra
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Settings
import PlotterControl.Settings.Utils


presetChanged : PlotterControl.Settings.Preset -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
presetChanged a model =
    ( { model
        | settings = model.settings |> (\x -> { x | preset = a })
      }
    , Cmd.none
    )
        |> Platform.Extra.andThen PlotterControl.Settings.Utils.configurePlotter

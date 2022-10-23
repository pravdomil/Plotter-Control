module PlotterControl.Settings.Utils exposing (..)

import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter.Utils
import PlotterControl.Settings
import SummaEl


configurePlotter : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
configurePlotter model =
    PlotterControl.Plotter.Utils.sendData
        (model.settings |> PlotterControl.Settings.toCommands |> Tuple.first |> SummaEl.toString)
        model

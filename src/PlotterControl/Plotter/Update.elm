module PlotterControl.Plotter.Update exposing (..)

import Platform.Extra
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter
import Task


stopPlotter : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
stopPlotter model =
    case model.plotter of
        Ok b ->
            ( model
            , PlotterControl.Plotter.stop b
                |> Task.attempt PlotterControl.Msg.SendingStopped
            )

        Err _ ->
            Platform.Extra.noOperation model

module PlotterControl.Plotter.Update exposing (..)

import Platform.Extra
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter
import Task


connect : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
connect model =
    ( { model | plotter = Err PlotterControl.Model.PlotterConnecting }
    , PlotterControl.Plotter.connect
        |> Task.attempt PlotterControl.Msg.PlotterReceived
    )


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

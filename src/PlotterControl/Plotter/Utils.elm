module PlotterControl.Plotter.Utils exposing (..)

import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter
import Task


sendData : String -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
sendData a model =
    ( { model | plotter = Err PlotterControl.Model.Connecting }
    , PlotterControl.Plotter.get
        |> Task.attempt (PlotterControl.Msg.PlotterReceived a)
    )

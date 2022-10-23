module PlotterControl.Plotter.Update exposing (..)

import Platform.Extra
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter
import Task


plotterReceived : Result PlotterControl.Plotter.Error PlotterControl.Plotter.Plotter -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
plotterReceived a model =
    ( { model
        | plotter = a |> Result.mapError PlotterControl.Model.PlotterError
        , queue = ""
      }
    , case a of
        Ok b ->
            PlotterControl.Plotter.sendData model.queue b
                |> Task.attempt PlotterControl.Msg.QueueSent

        Err _ ->
            Cmd.none
    )


queueSent : Result PlotterControl.Plotter.Error () -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd msg )
queueSent a model =
    let
        plotter : Result PlotterControl.Model.PlotterError PlotterControl.Plotter.Plotter
        plotter =
            case a of
                Ok () ->
                    Err PlotterControl.Model.QueueSent

                Err b ->
                    Err (PlotterControl.Model.PlotterError b)
    in
    ( { model | plotter = plotter }
    , Cmd.none
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

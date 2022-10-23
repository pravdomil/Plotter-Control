module PlotterControl.Plotter.Update exposing (..)

import Platform.Extra
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter
import Task


dataSent : Result PlotterControl.Plotter.Error () -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd msg )
dataSent a model =
    let
        plotter : Result PlotterControl.Model.PlotterError PlotterControl.Plotter.Plotter
        plotter =
            case a of
                Ok () ->
                    Err PlotterControl.Model.FileSent

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

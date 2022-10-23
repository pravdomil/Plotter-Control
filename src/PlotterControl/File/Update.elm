module PlotterControl.File.Update exposing (..)

import File.Select
import PlotterControl.Model
import PlotterControl.Msg


openFile : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
openFile model =
    ( model
    , File.Select.file [] PlotterControl.Msg.FileReceived
    )

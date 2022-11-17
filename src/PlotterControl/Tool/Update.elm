module PlotterControl.Tool.Update exposing (..)

import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Page
import PlotterControl.Tool


activateTool : PlotterControl.Tool.Tool -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
activateTool tool model =
    ( { model | page = Just (PlotterControl.Page.Tool_ (PlotterControl.Page.Tool tool)) }
    , Cmd.none
    )

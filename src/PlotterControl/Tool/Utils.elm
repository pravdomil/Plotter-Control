module PlotterControl.Tool.Utils exposing (..)

import PlotterControl.Model
import PlotterControl.Page
import PlotterControl.Tool


activeTool : PlotterControl.Model.Model -> Maybe PlotterControl.Tool.Tool
activeTool model =
    case model.page of
        Just (PlotterControl.Page.Tool_ b) ->
            Just b.tool

        _ ->
            Nothing

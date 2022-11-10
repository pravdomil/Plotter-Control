module PlotterControl.Checklist.Utils exposing (..)

import PlotterControl.Checklist
import PlotterControl.Model
import PlotterControl.Page


activeChecklist : PlotterControl.Model.Model -> Maybe PlotterControl.Checklist.Checklist
activeChecklist model =
    case model.page of
        Just (PlotterControl.Page.Checklist_ b) ->
            Just b.checklist

        _ ->
            Nothing

module PlotterControl.Checklist.Utils exposing (..)

import PlotterControl.Checklist
import PlotterControl.Model


activeChecklist : PlotterControl.Model.Model -> Maybe PlotterControl.Checklist.Checklist
activeChecklist model =
    case model.page of
        Just (PlotterControl.Model.Checklist b) ->
            Just b

        _ ->
            Nothing

module PlotterControl.Checklist.Update exposing (..)

import Dict.Any
import PlotterControl.Checklist
import PlotterControl.Model
import PlotterControl.Msg


activateChecklist : PlotterControl.Checklist.Checklist -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
activateChecklist a model =
    ( { model | page = Just (PlotterControl.Model.Checklist a) }
    , Cmd.none
    )


checkItem : PlotterControl.Checklist.Item -> Bool -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
checkItem item checked model =
    ( { model
        | checkList =
            if checked then
                Dict.Any.insert PlotterControl.Checklist.toComparable item () model.checkList

            else
                Dict.Any.remove PlotterControl.Checklist.toComparable item model.checkList
      }
    , Cmd.none
    )


resetChecklist : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
resetChecklist model =
    ( { model | checkList = Dict.Any.empty }
    , Cmd.none
    )

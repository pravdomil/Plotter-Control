module PlotterControl.Settings.Update exposing (..)

import Length
import Platform.Extra
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Settings
import PlotterControl.Settings.Utils
import Quantity


presetChanged : PlotterControl.Settings.Preset -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
presetChanged a model =
    ( { model
        | settings = model.settings |> (\x -> { x | preset = a })
      }
    , Cmd.none
    )
        |> Platform.Extra.andThen PlotterControl.Settings.Utils.configurePlotter


copiesChanged : PlotterControl.Settings.Copies -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
copiesChanged a model =
    ( { model
        | settings = (\x -> { x | copies = x.copies |> PlotterControl.Settings.copiesPlus a }) model.settings
      }
    , Cmd.none
    )


copyDistanceChanged : Length.Length -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
copyDistanceChanged a model =
    ( { model
        | settings = (\x -> { x | copyDistance = x.copyDistance |> Quantity.plus a |> Quantity.max (Length.millimeters 0) }) model.settings
      }
    , Cmd.none
    )


markerLoadingChanged : PlotterControl.Settings.MarkerLoading -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
markerLoadingChanged a model =
    ( { model
        | settings = model.settings |> (\x -> { x | markerLoading = a })
      }
    , Cmd.none
    )

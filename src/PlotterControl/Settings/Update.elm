module PlotterControl.Settings.Update exposing (..)

import Length
import Platform.Extra
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Settings
import PlotterControl.Settings.Utils
import Quantity


changePreset : PlotterControl.Settings.Preset -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changePreset a model =
    ( { model
        | settings = model.settings |> (\x -> { x | preset = a })
      }
    , Cmd.none
    )
        |> Platform.Extra.andThen PlotterControl.Settings.Utils.configurePlotter


changeCopies : PlotterControl.Settings.Copies -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeCopies a model =
    ( { model
        | settings = (\x -> { x | copies = x.copies |> PlotterControl.Settings.copiesPlus a }) model.settings
      }
    , Cmd.none
    )


changeCopyDistance : Length.Length -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeCopyDistance a model =
    ( { model
        | settings = (\x -> { x | copyDistance = x.copyDistance |> Quantity.plus a |> Quantity.max (Length.millimeters 0) }) model.settings
      }
    , Cmd.none
    )


changeMarkerLoading : PlotterControl.Settings.MarkerLoading -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeMarkerLoading a model =
    ( { model
        | settings = model.settings |> (\x -> { x | markerLoading = a })
      }
    , Cmd.none
    )

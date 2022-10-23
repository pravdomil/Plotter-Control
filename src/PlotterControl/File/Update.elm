module PlotterControl.File.Update exposing (..)

import Dict.Any
import Length
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Settings
import Quantity



--


update : PlotterControl.File.Name -> (PlotterControl.File.File -> PlotterControl.File.File) -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
update name fn model =
    ( { model
        | directory =
            Result.map
                (\x ->
                    { x
                        | files = Dict.Any.update PlotterControl.File.nameToString name (Maybe.map fn) x.files
                    }
                )
                model.directory
      }
    , Cmd.none
    )


updateReady : PlotterControl.File.Name -> (PlotterControl.File.Ready -> PlotterControl.File.Ready) -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
updateReady name fn model =
    update name (\x -> { x | ready = Result.map fn x.ready }) model


updateSettings : PlotterControl.File.Name -> (PlotterControl.Settings.Settings -> PlotterControl.Settings.Settings) -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
updateSettings name fn model =
    updateReady name (\x -> { x | settings = fn x.settings }) model



--


changePreset : PlotterControl.File.Name -> PlotterControl.Settings.Preset -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changePreset name a model =
    updateSettings name (\x -> { x | preset = a }) model


changeCopies : PlotterControl.File.Name -> PlotterControl.Settings.Copies -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeCopies name a model =
    updateSettings name (\x -> { x | copies = x.copies |> PlotterControl.Settings.copiesPlus a }) model


changeCopyDistance : PlotterControl.File.Name -> Length.Length -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeCopyDistance name a model =
    updateSettings name (\x -> { x | copyDistance = x.copyDistance |> Quantity.plus a |> Quantity.max (Length.millimeters 0) }) model


changeMarkerLoading : PlotterControl.File.Name -> PlotterControl.Settings.MarkerLoading -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeMarkerLoading name a model =
    updateSettings name (\x -> { x | markerLoading = a }) model

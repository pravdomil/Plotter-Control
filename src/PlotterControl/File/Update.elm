module PlotterControl.File.Update exposing (..)

import Dict.Any
import File
import File.Select
import HpGl
import Length
import Platform.Extra
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter.Utils
import PlotterControl.Settings
import PlotterControl.Settings.Utils
import Process
import Quantity
import SummaEl
import Task


openFile : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
openFile model =
    ( model
    , File.Select.file [] PlotterControl.Msg.FileReceived
    )


fileReceived : File.File -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
fileReceived a model =
    ( { model | file = Err PlotterControl.Model.Loading }
    , Process.sleep 10
        |> Task.andThen (\() -> File.toString a)
        |> Task.perform (PlotterControl.Msg.FileContentReceived a)
    )


fileContentReceived : File.File -> String -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
fileContentReceived a b model =
    ( { model | file = PlotterControl.File.fromFile a b |> Result.mapError PlotterControl.Model.FileError }
    , Cmd.none
    )


testMarkers : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
testMarkers model =
    case model.file of
        Ok b ->
            let
                data : String
                data =
                    [ model.settings |> PlotterControl.Settings.toCommands |> .settings |> SummaEl.toString
                    , b |> PlotterControl.File.toCommands |> .settings |> SummaEl.toString
                    ]
                        |> String.join "\n"
            in
            PlotterControl.Plotter.Utils.sendData data model

        Err _ ->
            Platform.Extra.noOperation model


sendFile : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
sendFile model =
    case model.file of
        Ok b ->
            let
                settings =
                    model.settings |> PlotterControl.Settings.toCommands

                file =
                    b |> PlotterControl.File.toCommands

                data : String
                data =
                    String.join "\n"
                        [ settings.settings |> SummaEl.toString
                        , file.settings |> SummaEl.toString
                        , file.data |> HpGl.toString
                        , settings.recut |> SummaEl.toString
                        ]
            in
            PlotterControl.Plotter.Utils.sendData data model

        Err _ ->
            Platform.Extra.noOperation model



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

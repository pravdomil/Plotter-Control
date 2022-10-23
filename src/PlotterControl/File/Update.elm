module PlotterControl.File.Update exposing (..)

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
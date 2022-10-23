module PlotterControl.Model.Update exposing (..)

import File
import HpGl
import Json.Decode
import Platform.Extra
import PlotterControl.File
import PlotterControl.File.Update
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter.Update
import PlotterControl.Plotter.Utils
import PlotterControl.Settings
import PlotterControl.Settings.Update
import Process
import SummaEl
import Task


init : Json.Decode.Value -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
init _ =
    ( { file = Err PlotterControl.Model.NotAsked
      , settings = PlotterControl.Settings.default
      , plotter = Err PlotterControl.Model.Ready
      , queue = ""
      }
    , Cmd.none
    )



--


update : PlotterControl.Msg.Msg -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
update msg model =
    case msg of
        PlotterControl.Msg.NothingHappened ->
            Platform.Extra.noOperation model

        PlotterControl.Msg.OpenFileRequested ->
            PlotterControl.File.Update.openFile model

        PlotterControl.Msg.FileReceived a ->
            ( { model | file = Err PlotterControl.Model.Loading }
            , Process.sleep 10
                |> Task.andThen (\() -> File.toString a)
                |> Task.perform (PlotterControl.Msg.FileContentReceived a)
            )

        PlotterControl.Msg.FileContentReceived a b ->
            ( { model | file = PlotterControl.File.fromFile a b |> Result.mapError PlotterControl.Model.FileError }
            , Cmd.none
            )

        PlotterControl.Msg.MarkerTestRequested ->
            case model.file of
                Ok b ->
                    let
                        data : String
                        data =
                            [ model.settings |> PlotterControl.Settings.toCommands |> Tuple.first |> SummaEl.toString
                            , b |> PlotterControl.File.toCommands |> Tuple.first |> SummaEl.toString
                            ]
                                |> String.join "\n"
                    in
                    PlotterControl.Plotter.Utils.sendData data model

                Err _ ->
                    Platform.Extra.noOperation model

        PlotterControl.Msg.SendFileRequested ->
            case model.file of
                Ok b ->
                    let
                        ( x, x2 ) =
                            model.settings |> PlotterControl.Settings.toCommands

                        ( x3, x4 ) =
                            b |> PlotterControl.File.toCommands

                        data : String
                        data =
                            String.join "\n"
                                [ x |> SummaEl.toString
                                , x3 |> SummaEl.toString
                                , x4 |> HpGl.toString
                                , x2 |> SummaEl.toString
                                ]
                    in
                    PlotterControl.Plotter.Utils.sendData data model

                Err _ ->
                    Platform.Extra.noOperation model

        PlotterControl.Msg.PresetChanged a ->
            PlotterControl.Settings.Update.presetChanged a model

        PlotterControl.Msg.CopiesChanged a ->
            PlotterControl.Settings.Update.copiesChanged a model

        PlotterControl.Msg.CopyDistanceChanged a ->
            PlotterControl.Settings.Update.copyDistanceChanged a model

        PlotterControl.Msg.MarkerLoadingChanged a ->
            PlotterControl.Settings.Update.markerLoadingChanged a model

        PlotterControl.Msg.PlotterReceived a ->
            PlotterControl.Plotter.Update.plotterReceived a model

        PlotterControl.Msg.QueueSent a ->
            PlotterControl.Plotter.Update.queueSent a model

        PlotterControl.Msg.StopSendingRequested ->
            PlotterControl.Plotter.Update.stopPlotter model

        PlotterControl.Msg.SendingStopped _ ->
            Platform.Extra.noOperation model



--


subscriptions : PlotterControl.Model.Model -> Sub PlotterControl.Msg.Msg
subscriptions _ =
    Sub.none

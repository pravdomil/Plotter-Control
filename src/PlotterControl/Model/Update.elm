module PlotterControl.Model.Update exposing (..)

import Dict.Any
import Json.Decode
import Platform.Extra
import PlotterControl.Checklist.Update
import PlotterControl.Directory.Update
import PlotterControl.File.Update
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter.Update
import PlotterControl.Queue.Update


init : Json.Decode.Value -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
init _ =
    ( PlotterControl.Model.Model
        (Err PlotterControl.Model.NotAsked)
        Dict.Any.empty
        (Err PlotterControl.Model.Ready)
        Dict.Any.empty
    , Cmd.none
    )



--


update : PlotterControl.Msg.Msg -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
update msg model =
    case msg of
        PlotterControl.Msg.NothingHappened ->
            Platform.Extra.noOperation model

        --
        PlotterControl.Msg.OpenDirectoryRequested ->
            PlotterControl.Directory.Update.openDirectory model

        PlotterControl.Msg.FileActivated a ->
            PlotterControl.Directory.Update.activateFile a model

        --
        PlotterControl.Msg.OpenFileRequested ->
            PlotterControl.File.Update.openFile model

        PlotterControl.Msg.FileReceived a ->
            PlotterControl.File.Update.fileReceived a model

        PlotterControl.Msg.FileContentReceived a b ->
            PlotterControl.File.Update.fileContentReceived a b model

        PlotterControl.Msg.MarkerTestRequested ->
            PlotterControl.File.Update.testMarkers model

        --
        PlotterControl.Msg.SendFileRequested ->
            PlotterControl.File.Update.sendFile model

        PlotterControl.Msg.PresetChanged a ->
            PlotterControl.Settings.Update.changePreset a model

        PlotterControl.Msg.CopiesChanged a ->
            PlotterControl.Settings.Update.changeCopies a model

        PlotterControl.Msg.CopyDistanceChanged a ->
            PlotterControl.Settings.Update.changeCopyDistance a model

        PlotterControl.Msg.MarkerLoadingChanged a ->
            PlotterControl.Settings.Update.changeMarkerLoading a model

        --
        PlotterControl.Msg.SendQueueRequested ->
            PlotterControl.Queue.Update.sendQueue model

        PlotterControl.Msg.QueueItemRemoveRequested a ->
            PlotterControl.Queue.Update.removeItemFromQueue a model

        --
        PlotterControl.Msg.PlotterReceived a ->
            PlotterControl.Plotter.Update.plotterReceived a model

        PlotterControl.Msg.PlotterDataSent a ->
            PlotterControl.Plotter.Update.dataSent a model

        PlotterControl.Msg.StopSendingRequested ->
            PlotterControl.Plotter.Update.stopPlotter model

        PlotterControl.Msg.SendingStopped _ ->
            Platform.Extra.noOperation model

        --
        PlotterControl.Msg.ChecklistItemChecked a b ->
            PlotterControl.Checklist.Update.checkItem a b model



--


subscriptions : PlotterControl.Model.Model -> Sub PlotterControl.Msg.Msg
subscriptions _ =
    Sub.none

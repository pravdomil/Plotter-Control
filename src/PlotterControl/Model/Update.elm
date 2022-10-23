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
        (Err ())
        Dict.Any.empty
        (Err PlotterControl.Model.NoPlotter)
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
        PlotterControl.Msg.OpenFilesRequested ->
            PlotterControl.Directory.Update.openFiles model

        PlotterControl.Msg.RawFilesReceived a ->
            PlotterControl.Directory.Update.rawFilesReceived a model

        PlotterControl.Msg.FilesReceived a ->
            PlotterControl.Directory.Update.filesReceived a model

        PlotterControl.Msg.FileActivated a ->
            PlotterControl.Directory.Update.activateFile a model

        --
        PlotterControl.Msg.AddFileToQueueRequested a ->
            PlotterControl.File.Update.addFileToQueue a model

        PlotterControl.Msg.MarkerTestRequested a ->
            PlotterControl.File.Update.testMarkers a model

        PlotterControl.Msg.ConfigurePlotterRequested a ->
            PlotterControl.File.Update.configurePlotter a model

        PlotterControl.Msg.PresetChanged a b ->
            PlotterControl.File.Update.changePreset a b model

        PlotterControl.Msg.CopiesChanged a b ->
            PlotterControl.File.Update.changeCopies a b model

        PlotterControl.Msg.CopyDistanceChanged a b ->
            PlotterControl.File.Update.changeCopyDistance a b model

        PlotterControl.Msg.MarkerLoadingChanged a b ->
            PlotterControl.File.Update.changeMarkerLoading a b model

        --
        PlotterControl.Msg.SendQueueRequested ->
            PlotterControl.Queue.Update.sendQueue model

        PlotterControl.Msg.QueueItemReceived a ->
            PlotterControl.Queue.Update.addItemToQueue a model

        PlotterControl.Msg.QueueItemRemoveRequested a ->
            PlotterControl.Queue.Update.removeItemFromQueue a model

        --
        PlotterControl.Msg.PlotterReceived a ->
            PlotterControl.Plotter.Update.plotterReceived a model

        PlotterControl.Msg.QueueItemSent a b c ->
            PlotterControl.Plotter.Update.queueItemSent a b c model

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

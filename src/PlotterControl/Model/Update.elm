module PlotterControl.Model.Update exposing (..)

import Dict.Any
import Element.PravdomilUi.Application
import Json.Decode
import Json.Encode
import Length
import Mass
import Platform.Extra
import PlotterControl.Checklist.Update
import PlotterControl.Commander.Update
import PlotterControl.Directory.Update
import PlotterControl.File.Update
import PlotterControl.MarkerSensitivity
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter.Update
import PlotterControl.Queue.Update
import PlotterControl.Tool.Update
import PlotterControl.Utils.Utils


init : Json.Decode.Value -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
init flags =
    ( PlotterControl.Model.Model
        (Element.PravdomilUi.Application.flagsToViewportSize flags)
        Nothing
        Dict.Any.empty
        (Err ())
        Dict.Any.empty
        (Err PlotterControl.Model.NoPlotter)
        (PlotterControl.MarkerSensitivity.percentage 75)
        (PlotterControl.Utils.Utils.millimetersPerSecond 200)
        (Mass.grams 160)
        (PlotterControl.Utils.Utils.millimetersPerSecond 800)
        PlotterControl.Utils.Utils.layerCutPressure
        (Length.millimeters 0.5)
        (Length.millimeters 1)
        (Length.millimeters 0.6)
        PlotterControl.Commander.Update.init
    , Cmd.none
    )



--


update : PlotterControl.Msg.Msg -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
update msg model =
    case msg of
        PlotterControl.Msg.NothingHappened ->
            Platform.Extra.noOperation model

        PlotterControl.Msg.ViewportSizeChanged a ->
            ( { model | viewportSize = a }, Cmd.none )

        PlotterControl.Msg.Reset ->
            init Json.Encode.null
                |> Tuple.mapFirst (\x -> { x | viewportSize = model.viewportSize, page = model.page, directory = model.directory })

        --
        PlotterControl.Msg.ChecklistActivated a ->
            PlotterControl.Checklist.Update.activateChecklist a model

        PlotterControl.Msg.ChecklistItemChecked a b ->
            PlotterControl.Checklist.Update.checkItem a b model

        PlotterControl.Msg.MarkerSensitivityChanged a ->
            PlotterControl.Checklist.Update.changeMarkerSensitivity a model

        PlotterControl.Msg.MarkerTestRequested ->
            PlotterControl.Checklist.Update.testMarkers model

        PlotterControl.Msg.DrawingSpeedChanged a ->
            PlotterControl.Checklist.Update.changeDrawingSpeed a model

        PlotterControl.Msg.DrawingPressureChanged a ->
            PlotterControl.Checklist.Update.changeDrawingPressure a model

        PlotterControl.Msg.DrawingTestRequested ->
            PlotterControl.Checklist.Update.testDrawing model

        PlotterControl.Msg.CuttingSpeedChanged a ->
            PlotterControl.Checklist.Update.changeCuttingSpeed a model

        PlotterControl.Msg.CuttingPressureChanged a ->
            PlotterControl.Checklist.Update.changeCuttingPressure a model

        PlotterControl.Msg.CuttingOffsetChanged a ->
            PlotterControl.Checklist.Update.changeCuttingOffset a model

        PlotterControl.Msg.CuttingTestRequested ->
            PlotterControl.Checklist.Update.testCutting model

        PlotterControl.Msg.PerforationSpacingChanged a ->
            PlotterControl.Checklist.Update.changePerforationSpacing a model

        PlotterControl.Msg.PerforationOffsetChanged a ->
            PlotterControl.Checklist.Update.changePerforationOffset a model

        PlotterControl.Msg.PerforationTestRequested ->
            PlotterControl.Checklist.Update.testPerforation model

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
        PlotterControl.Msg.ToolActivated a ->
            PlotterControl.Tool.Update.activateTool a model

        --
        PlotterControl.Msg.CommanderCommandTypeChanged a ->
            PlotterControl.Commander.Update.changeCommandType a model

        PlotterControl.Msg.CommanderCommandChanged a ->
            PlotterControl.Commander.Update.changeCommand a model

        PlotterControl.Msg.CommanderSendRequested ->
            PlotterControl.Commander.Update.sendCommand model

        PlotterControl.Msg.CommanderSensorLeftOffsetChanged a ->
            PlotterControl.Commander.Update.changeSensorLeftOffset a model

        PlotterControl.Msg.CommanderSensorUpOffsetChanged a ->
            PlotterControl.Commander.Update.changeSensorUpOffset a model

        PlotterControl.Msg.CommanderSensorCalibrateRequested ->
            PlotterControl.Commander.Update.calibrateSensor model

        --
        PlotterControl.Msg.AddFileToQueueRequested a ->
            PlotterControl.File.Update.addFileToQueue a model

        PlotterControl.Msg.DownloadSvgRequested a ->
            PlotterControl.File.Update.downloadSvg a model

        PlotterControl.Msg.FileMarkerTestRequested a ->
            PlotterControl.File.Update.testMarkers a model

        PlotterControl.Msg.PresetChanged a b ->
            PlotterControl.File.Update.changePreset a b model

        PlotterControl.Msg.CopiesChanged a b ->
            PlotterControl.File.Update.changeCopies a b model

        PlotterControl.Msg.CopyDistanceChanged a b ->
            PlotterControl.File.Update.changeCopyDistance a b model

        PlotterControl.Msg.MarkerLoadingChanged a b ->
            PlotterControl.File.Update.changeMarkerLoading a b model

        --
        PlotterControl.Msg.QueueItemReceived a ->
            PlotterControl.Queue.Update.addItemToQueue a model

        PlotterControl.Msg.QueueItemRemoveRequested a ->
            PlotterControl.Queue.Update.removeItemFromQueue a model

        PlotterControl.Msg.QueueDownloadRequested ->
            PlotterControl.Queue.Update.download model

        --
        PlotterControl.Msg.SendQueueRequested ->
            PlotterControl.Plotter.Update.sendQueue model

        PlotterControl.Msg.PlotterConnected a ->
            PlotterControl.Plotter.Update.plotterConnected a model

        PlotterControl.Msg.QueueItemSent a b c ->
            PlotterControl.Plotter.Update.queueItemSent a b c model

        PlotterControl.Msg.StopSendingRequested ->
            PlotterControl.Plotter.Update.stopPlotter model

        PlotterControl.Msg.SendingStopped _ ->
            Platform.Extra.noOperation model



--


subscriptions : PlotterControl.Model.Model -> Sub PlotterControl.Msg.Msg
subscriptions _ =
    Element.PravdomilUi.Application.onViewportSizeChange PlotterControl.Msg.ViewportSizeChanged

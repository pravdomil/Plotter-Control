module PlotterControl.Model.Update exposing (..)

import Json.Decode
import Platform.Extra
import PlotterControl.File.Update
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter.Update
import PlotterControl.Settings
import PlotterControl.Settings.Update


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
            PlotterControl.File.Update.fileReceived a model

        PlotterControl.Msg.FileContentReceived a b ->
            PlotterControl.File.Update.fileContentReceived a b model

        PlotterControl.Msg.MarkerTestRequested ->
            PlotterControl.File.Update.testMarkers model

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

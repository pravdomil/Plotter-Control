module PlotterControl.Msg exposing (..)

import File
import Id
import Length
import PlotterControl.Checklist
import PlotterControl.File
import PlotterControl.Plotter
import PlotterControl.Queue
import PlotterControl.Settings


type Msg
    = NothingHappened
      --
    | OpenDirectoryRequested
    | FileActivated PlotterControl.File.Name
      --
    | OpenFileRequested
    | FileReceived File.File
    | FileContentReceived File.File String
    | AddToQueueRequested
      --
    | MarkerTestRequested PlotterControl.File.Name
    | PresetChanged PlotterControl.File.Name PlotterControl.Settings.Preset
    | CopiesChanged PlotterControl.File.Name PlotterControl.Settings.Copies
    | CopyDistanceChanged PlotterControl.File.Name Length.Length
    | MarkerLoadingChanged PlotterControl.File.Name PlotterControl.Settings.MarkerLoading
      --
    | SendQueueRequested
    | QueueItemRemoveRequested (Id.Id PlotterControl.Queue.Item)
    | PlotterReceived (Result PlotterControl.Plotter.Error PlotterControl.Plotter.Plotter)
    | QueueSent (Result PlotterControl.Plotter.Error ())
    | StopSendingRequested
    | SendingStopped (Result PlotterControl.Plotter.Error ())
      --
    | ChecklistItemChecked PlotterControl.Checklist.Item Bool

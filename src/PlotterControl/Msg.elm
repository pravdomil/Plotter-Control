module PlotterControl.Msg exposing (..)

import Element.PravdomilUi.Application
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
    | ViewportSizeChanged Element.PravdomilUi.Application.ViewportSize
      --
    | ChecklistActivated PlotterControl.Checklist.Checklist
    | MarkerSensitivityChanged Int
      --
    | OpenFilesRequested
    | RawFilesReceived (List File.File)
    | FilesReceived (List ( PlotterControl.File.Name, PlotterControl.File.File ))
    | FileActivated PlotterControl.File.Name
      --
    | AddFileToQueueRequested PlotterControl.File.Name
    | MarkerTestRequested PlotterControl.File.Name
    | PresetChanged PlotterControl.File.Name PlotterControl.Settings.Preset
    | CopiesChanged PlotterControl.File.Name PlotterControl.Settings.Copies
    | CopyDistanceChanged PlotterControl.File.Name Length.Length
    | MarkerLoadingChanged PlotterControl.File.Name PlotterControl.Settings.MarkerLoading
      --
    | QueueItemReceived ( Id.Id PlotterControl.Queue.Item, PlotterControl.Queue.Item )
    | QueueItemRemoveRequested (Id.Id PlotterControl.Queue.Item)
      --
    | SendQueueRequested
    | PlotterConnected (Result PlotterControl.Plotter.Error PlotterControl.Plotter.Plotter)
    | QueueItemSent PlotterControl.Plotter.Plotter (Id.Id PlotterControl.Queue.Item) (Result PlotterControl.Plotter.Error ())
    | StopSendingRequested
    | SendingStopped (Result PlotterControl.Plotter.Error ())
      --
    | ChecklistItemChecked PlotterControl.Checklist.Item Bool
    | ResetChecklist

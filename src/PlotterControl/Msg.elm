module PlotterControl.Msg exposing (..)

import Element.PravdomilUi.Application
import File
import Id
import Length
import Mass
import PlotterControl.Checklist
import PlotterControl.Commander
import PlotterControl.File
import PlotterControl.MarkerSensitivity
import PlotterControl.Plotter
import PlotterControl.Queue
import PlotterControl.Settings
import PlotterControl.Tool
import Speed


type Msg
    = NothingHappened
    | ViewportSizeChanged Element.PravdomilUi.Application.ViewportSize
    | Reset
      --
    | ChecklistActivated PlotterControl.Checklist.Checklist
    | ChecklistItemChecked PlotterControl.Checklist.Item Bool
      --
    | MarkerSensitivityChanged PlotterControl.MarkerSensitivity.MarkerSensitivity
    | MarkerTestRequested
      --
    | DrawingSpeedChanged Speed.Speed
    | DrawingPressureChanged Mass.Mass
    | DrawingTestRequested
      --
    | CuttingSpeedChanged Speed.Speed
    | CuttingPressureChanged Mass.Mass
    | CuttingOffsetChanged Length.Length
    | CuttingTestRequested
      --
    | PerforationSpacingChanged Length.Length
    | PerforationOffsetChanged Length.Length
    | PerforationTestRequested PerforationTest
      --
    | OpenFilesRequested
    | RawFilesReceived (List File.File)
    | FilesReceived (List ( PlotterControl.File.Name, PlotterControl.File.File ))
    | FileActivated PlotterControl.File.Name
      --
    | ToolActivated PlotterControl.Tool.Tool
      --
    | CommanderCommandTypeChanged PlotterControl.Commander.CommandType
    | CommanderCommandChanged String
    | CommanderSendRequested
    | CommanderSensorLeftOffsetChanged Length.Length
    | CommanderSensorUpOffsetChanged Length.Length
      --
    | AddFileToQueueRequested PlotterControl.File.Name
    | DownloadSvgRequested PlotterControl.File.Name
    | FileMarkerTestRequested PlotterControl.File.Name
    | PresetChanged PlotterControl.File.Name PlotterControl.Settings.Preset
    | CopiesChanged PlotterControl.File.Name PlotterControl.Settings.Copies
    | CopyDistanceChanged PlotterControl.File.Name Length.Length
    | MarkerLoadingChanged PlotterControl.File.Name PlotterControl.Settings.MarkerLoading
      --
    | QueueItemReceived ( Id.Id PlotterControl.Queue.Item, PlotterControl.Queue.Item )
    | QueueItemRemoveRequested (Id.Id PlotterControl.Queue.Item)
    | QueueDownloadRequested
      --
    | SendQueueRequested
    | PlotterConnected (Result PlotterControl.Plotter.Error PlotterControl.Plotter.Plotter)
    | QueueItemSent PlotterControl.Plotter.Plotter (Id.Id PlotterControl.Queue.Item) (Result PlotterControl.Plotter.Error ())
    | StopSendingRequested
    | SendingStopped (Result PlotterControl.Plotter.Error ())



--


type PerforationTest
    = PerforationTestSquare
    | PerforationTestLine

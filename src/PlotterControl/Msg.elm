module PlotterControl.Msg exposing (..)

import File
import Length
import PlotterControl.Plotter
import PlotterControl.Settings


type Msg
    = NothingHappened
      --
    | OpenFileRequested
    | FileReceived File.File
    | FileContentReceived File.File String
    | SendFileRequested
      --
    | MarkerTestRequested
    | PresetChanged PlotterControl.Settings.Preset
    | CopiesChanged PlotterControl.Settings.Copies
    | CopyDistanceChanged Length.Length
    | MarkerLoadingChanged PlotterControl.Settings.MarkerLoading
      --
    | PlotterReceived (Result PlotterControl.Plotter.Error PlotterControl.Plotter.Plotter)
    | QueueSent (Result PlotterControl.Plotter.Error ())
    | StopSendingRequested
    | SendingStopped (Result PlotterControl.Plotter.Error ())

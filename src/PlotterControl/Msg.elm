module PlotterControl.Msg exposing (..)

import File
import Length
import PlotterControl.Plotter
import PlotterControl.Settings


type Msg
    = NothingHappened
    | OpenFileRequested
    | FileReceived File.File
    | FileContentReceived File.File String
      --
    | MarkerTestRequested
    | PresetChanged PlotterControl.Settings.Preset
    | CopiesChanged PlotterControl.Settings.Copies
    | CopyDistanceChanged Length.Length
    | MarkerLoadingChanged PlotterControl.Settings.MarkerLoading
      --
    | SendFileRequested
      --
    | PlotterReceived String (Result PlotterControl.Plotter.Error PlotterControl.Plotter.Plotter)
    | DataSent (Result PlotterControl.Plotter.Error ())
    | StopSendingRequested
    | SendingStopped (Result PlotterControl.Plotter.Error ())

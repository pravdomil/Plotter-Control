module PlotterControl.Msg exposing (..)

import File
import Length
import PlotterControl.Plotter
import PlotterControl.Settings


type Msg
    = NothingHappened
    | OpenFile
    | GotFile File.File
    | GotFileContent File.File String
      --
    | TestMarkers
    | ChangePreset PlotterControl.Settings.Preset
    | PlusCopies PlotterControl.Settings.Copies
    | PlusCopyDistance Length.Length
    | ChangeMarkerLoading PlotterControl.Settings.MarkerLoading
      --
    | SendFile
      --
    | SendData String
    | GotPlotterSendData String (Result PlotterControl.Plotter.Error PlotterControl.Plotter.Plotter)
    | DataSent (Result PlotterControl.Plotter.Error ())
    | StopSending
    | SendingStopped (Result PlotterControl.Plotter.Error ())

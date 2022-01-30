module PlotterControl.Model exposing (..)

import File
import Length
import PlotterControl.File
import PlotterControl.Plotter
import PlotterControl.Settings


type alias Model =
    { file : Result FileError PlotterControl.File.File
    , settings : PlotterControl.Settings.Settings
    , plotter : Result PlotterError PlotterControl.Plotter.Plotter
    }



--


type FileError
    = NotAsked
    | Loading
    | FileError PlotterControl.File.Error



--


type PlotterError
    = Ready
    | Connecting
    | FileSent
    | PlotterError PlotterControl.Plotter.Error



--


type Msg
    = OpenFile
    | GotFile File.File
    | GotFileContent File.File String
    | DragOver
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

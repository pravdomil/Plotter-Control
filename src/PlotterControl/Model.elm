module PlotterControl.Model exposing (..)

import PlotterControl.File
import PlotterControl.Plotter
import PlotterControl.Settings


type alias Model =
    { file : Result FileError PlotterControl.File.File
    , settings : PlotterControl.Settings.Settings
    , plotter : Result PlotterError PlotterControl.Plotter.Plotter
    , queue : String
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

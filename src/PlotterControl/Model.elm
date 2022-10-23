module PlotterControl.Model exposing (..)

import Dict.Any
import PlotterControl.Checklist
import PlotterControl.Directory
import PlotterControl.Plotter
import PlotterControl.Queue


type alias Model =
    { directory : Result () PlotterControl.Directory.Directory
    , queue : PlotterControl.Queue.Queue
    , plotter : Result PlotterError PlotterControl.Plotter.Plotter
    , checkList : Dict.Any.Dict PlotterControl.Checklist.Item ()
    }



--


type PlotterError
    = Ready
    | Connecting
    | QueueSent
    | PlotterError PlotterControl.Plotter.Error

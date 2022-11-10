module PlotterControl.Model exposing (..)

import Dict.Any
import Element.PravdomilUi.Application
import PlotterControl.Checklist
import PlotterControl.Directory
import PlotterControl.File
import PlotterControl.Plotter
import PlotterControl.Queue


type alias Model =
    { viewportSize : Element.PravdomilUi.Application.ViewportSize

    --
    , page : Maybe Page
    , directory : Result () PlotterControl.Directory.Directory
    , queue : PlotterControl.Queue.Queue
    , plotter : Result PlotterError PlotterControl.Plotter.Plotter
    , checkList : Dict.Any.Dict PlotterControl.Checklist.Item ()
    }



--


type Page
    = MediaChecklist
    | MarkersChecklist
    | DrawChecklist
    | CutChecklist
    | PerforationChecklist
    | File PlotterControl.File.Name



--


type PlotterError
    = NoPlotter
    | PlotterConnecting
    | PlotterSending PlotterControl.Plotter.Plotter
    | PlotterError PlotterControl.Plotter.Error

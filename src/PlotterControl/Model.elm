module PlotterControl.Model exposing (..)

import Dict.Any
import Element.PravdomilUi.Application
import PlotterControl.Checklist
import PlotterControl.Directory
import PlotterControl.Page
import PlotterControl.Plotter
import PlotterControl.Queue


type alias Model =
    { viewportSize : Element.PravdomilUi.Application.ViewportSize

    --
    , page : Maybe PlotterControl.Page.Page
    , directory : Result () PlotterControl.Directory.Directory
    , queue : PlotterControl.Queue.Queue
    , plotter : Result PlotterError PlotterControl.Plotter.Plotter
    , checklist : Dict.Any.Dict PlotterControl.Checklist.Item ()

    --
    , markerSensitivity : Int

    --
    , drawingSpeed : Int
    , drawingPressure : Int

    --
    , cuttingSpeed : Int
    , cuttingPressure : Int
    , cuttingOffset : Int

    --
    , perforationSpacing : Int
    , perforationOffset : Int
    }



--


type PlotterError
    = NoPlotter
    | PlotterConnecting
    | PlotterSending PlotterControl.Plotter.Plotter
    | PlotterError PlotterControl.Plotter.Error

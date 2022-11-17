module PlotterControl.Model exposing (..)

import Dict.Any
import Element.PravdomilUi.Application
import Length
import Mass
import PlotterControl.Checklist
import PlotterControl.Directory
import PlotterControl.Page
import PlotterControl.Plotter
import PlotterControl.Queue
import Quantity
import Speed


type alias Model =
    { viewportSize : Element.PravdomilUi.Application.ViewportSize

    --
    , page : Maybe PlotterControl.Page.Page
    , checklist : Dict.Any.Dict PlotterControl.Checklist.Item ()
    , directory : Result () PlotterControl.Directory.Directory
    , queue : PlotterControl.Queue.Queue
    , plotter : Result PlotterError PlotterControl.Plotter.Plotter

    --
    , markerSensitivity : MarkerSensitivity

    --
    , drawingSpeed : Speed.Speed
    , drawingPressure : Mass.Mass

    --
    , cuttingSpeed : Speed.Speed
    , cuttingPressure : Mass.Mass
    , cuttingOffset : Length.Length

    --
    , perforationSpacing : Length.Length
    , perforationOffset : Length.Length
    }



--


type alias MarkerSensitivity =
    Quantity.Quantity Int Sensitivity



--


type Sensitivity
    = Sensitivity



--


type PlotterError
    = NoPlotter
    | PlotterConnecting
    | PlotterSending PlotterControl.Plotter.Plotter
    | PlotterError PlotterControl.Plotter.Error

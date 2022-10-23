module PlotterControl.Directory exposing (..)

import Dict.Any
import PlotterControl.File


type alias Directory =
    { files : Dict.Any.Dict PlotterControl.File.Name PlotterControl.File.File
    , active : Maybe PlotterControl.File.Name
    }

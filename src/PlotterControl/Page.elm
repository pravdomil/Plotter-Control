module PlotterControl.Page exposing (..)

import PlotterControl.Checklist
import PlotterControl.File
import PlotterControl.Tool


type Page
    = Checklist_ Checklist
    | File_ File
    | Tool_ Tool



--


type alias Checklist =
    { checklist : PlotterControl.Checklist.Checklist
    }



--


type alias File =
    { name : PlotterControl.File.Name
    }



--


type alias Tool =
    { tool : PlotterControl.Tool.Tool
    }

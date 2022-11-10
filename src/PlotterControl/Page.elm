module PlotterControl.Page exposing (..)

import PlotterControl.Checklist
import PlotterControl.File


type Page
    = Checklist_ Checklist
    | File_ File



--


type alias Checklist =
    { checklist : PlotterControl.Checklist.Checklist
    }



--


type alias File =
    { name : PlotterControl.File.Name
    }

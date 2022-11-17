module PlotterControl.Tool.View exposing (..)

import Element.PravdomilUi.Application
import PlotterControl.Commander.View
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Page
import PlotterControl.Tool


view : PlotterControl.Page.Tool -> PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view tool model =
    case tool.tool of
        PlotterControl.Tool.Commander ->
            PlotterControl.Commander.View.view model

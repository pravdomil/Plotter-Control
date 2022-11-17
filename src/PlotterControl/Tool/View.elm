module PlotterControl.Tool.View exposing (..)

import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Page
import PlotterControl.Tool


view : PlotterControl.Page.Tool -> PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view tool model =
    case tool.tool of
        PlotterControl.Tool.Commander ->
            viewCommander model


viewCommander : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
viewCommander _ =
    { size = \x -> { x | width = clamp 240 448 (x.width // 3) }
    , header =
        Just
            { attributes = []
            , left = []
            , center = text "Commander"
            , right = []
            }
    , toolbar = Nothing
    , body = Element.PravdomilUi.Application.Blocks []
    }

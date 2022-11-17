module PlotterControl.Commander.View exposing (..)

import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import PlotterControl.Model
import PlotterControl.Msg


view : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view _ =
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

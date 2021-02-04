module App.App.App exposing (..)

import App.PlotterControl.PlotterControl exposing (PlotterControl, PlotterControlMsg)


{-| To define things we keep.
-}
type alias Model =
    { plotterControl : PlotterControl
    }


{-| To define what can happen.
-}
type Msg
    = PlotterControlMsg PlotterControlMsg

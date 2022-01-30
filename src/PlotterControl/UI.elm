module PlotterControl.UI exposing (..)

import Element.PravdomilUI exposing (..)
import Element.PravdomilUI.LightTheme exposing (..)


theme =
    Element.PravdomilUI.LightTheme.theme


dangerBackground : Attribute msg
dangerBackground =
    bgColor danger

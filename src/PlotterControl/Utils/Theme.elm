module PlotterControl.Utills.Theme exposing (..)

import Element.PravdomilUI exposing (..)
import Element.PravdomilUI.Theme.Light


theme =
    Element.PravdomilUI.Theme.Light.theme Element.PravdomilUI.Theme.Light.style


dangerBackground : Attribute msg
dangerBackground =
    bgColor Element.PravdomilUI.Theme.Light.style.danger

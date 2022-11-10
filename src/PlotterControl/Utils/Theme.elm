module PlotterControl.Utils.Theme exposing (..)

import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Theme
import Element.PravdomilUi.Theme.Basic


style =
    Element.PravdomilUi.Theme.Basic.style


theme =
    Element.PravdomilUi.Theme.Basic.theme style


statusText : Element.PravdomilUi.Theme.Theme msg -> List (Attribute msg) -> String -> Element msg
statusText _ attrs a =
    el (width fill :: height (px 40) :: fontSize 15 :: fontColor style.fore60 :: attrs) (textEllipsis [ centerY ] a)

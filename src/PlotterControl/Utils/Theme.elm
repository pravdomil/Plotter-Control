module PlotterControl.Utils.Theme exposing (..)

import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Theme
import Element.PravdomilUi.Theme.Basic


style =
    Element.PravdomilUi.Theme.Basic.style


theme =
    Element.PravdomilUi.Theme.Basic.theme style


statusParagraph : Element.PravdomilUi.Theme.Theme msg -> List (Attribute msg) -> List (Element msg) -> Element msg
statusParagraph theme_ attrs a =
    paragraph theme_ (fontSize 15 :: fontColor style.fore60 :: attrs) a

module PlotterControl.Utils.View exposing (..)

import Element.PravdomilUi exposing (..)
import FeatherIcons
import PlotterControl.Utils.Theme exposing (..)


twoColumns : Element msg -> Element msg -> Element msg
twoColumns a b =
    row [ spacing 8 ]
        [ el (theme.label [ width fill, fontAlignRight ]) a
        , el [ width fill ] b
        ]


inputNumber : Element msg -> (Int -> msg) -> Element msg
inputNumber value onChange =
    row [ spacing 8 ]
        [ textButton theme
            []
            { label = FeatherIcons.minus |> FeatherIcons.withSize 30 |> iconToElement
            , onPress = onChange -10 |> Just
            }
        , textButton theme
            []
            { label = FeatherIcons.minus |> FeatherIcons.withSize 20 |> iconToElement
            , onPress = onChange -1 |> Just
            }
        , el [ fontVariant fontTabularNumbers ] value
        , textButton theme
            []
            { label = FeatherIcons.plus |> FeatherIcons.withSize 20 |> iconToElement
            , onPress = onChange 1 |> Just
            }
        , textButton theme
            []
            { label = FeatherIcons.plus |> FeatherIcons.withSize 30 |> iconToElement
            , onPress = onChange 10 |> Just
            }
        ]


iconToElement : FeatherIcons.Icon -> Element msg
iconToElement a =
    a
        |> FeatherIcons.toHtml []
        |> html
        |> el []

module PlotterControl.Utils.View exposing (..)

import Element.PravdomilUi exposing (..)
import FeatherIcons
import PlotterControl.Utils.Theme exposing (..)
import Quantity


twoColumns : String -> Element msg -> Element msg
twoColumns a b =
    row [ width fill, spacing 8 ]
        [ el (theme.label [ width (px 128), height (px 40), alignTop ]) (textEllipsis [ centerY, fontAlignRight ] a)
        , b
        ]


inputNumber : Element msg -> (Int -> msg) -> Element msg
inputNumber value onChange =
    row [ width fill, spacing 8 ]
        [ el [ width fill, fontVariant fontTabularNumbers ] value
        , textButton theme
            []
            { label = FeatherIcons.minus |> FeatherIcons.withSize 20 |> iconToElement
            , onPress = onChange -1 |> Just
            }
        , textButton theme
            []
            { label = FeatherIcons.plus |> FeatherIcons.withSize 20 |> iconToElement
            , onPress = onChange 1 |> Just
            }
        , textButton theme
            []
            { label =
                row []
                    [ FeatherIcons.minus |> FeatherIcons.withSize 20 |> iconToElement
                    , text " 10"
                    ]
            , onPress = onChange -10 |> Just
            }
        , textButton theme
            []
            { label =
                row []
                    [ FeatherIcons.plus |> FeatherIcons.withSize 20 |> iconToElement
                    , text " 10"
                    ]
            , onPress = onChange 10 |> Just
            }
        ]


inputHelper : String -> String -> Element msg -> Quantity.Quantity number units -> (Quantity.Quantity number units -> msg) -> Element msg
inputHelper label value note step onChange =
    twoColumns
        label
        (row [ width fill, spacing 8 ]
            [ el [ width (px 80), fontVariant fontTabularNumbers ] (text value)
            , textButton theme
                []
                { label = FeatherIcons.minus |> FeatherIcons.withSize 20 |> iconToElement
                , onPress = Just (onChange (step |> Quantity.negate))
                }
            , textButton theme
                []
                { label = FeatherIcons.plus |> FeatherIcons.withSize 20 |> iconToElement
                , onPress = Just (onChange step)
                }
            , el [ fontSize 15, fontColor style.fore60 ] note
            ]
        )


iconToElement : FeatherIcons.Icon -> Element msg
iconToElement a =
    a
        |> FeatherIcons.toHtml []
        |> html
        |> el []

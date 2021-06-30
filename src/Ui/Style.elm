module Ui.Style exposing (..)

import Element



-- Colors


gray0 =
    Element.rgb 1 1 1


gray1 =
    Element.rgb 0.96 0.97 0.97


gray2 =
    Element.rgb 0.9 0.92 0.93


gray3 =
    Element.rgb 0.86 0.88 0.89


gray4 =
    Element.rgb 0.8 0.82 0.84


gray5 =
    Element.rgb 0.67 0.7 0.73


gray6 =
    Element.rgb 0.41 0.45 0.48


gray7 =
    Element.rgb 0.28 0.3 0.33


gray8 =
    Element.rgb 0.19 0.22 0.24


gray9 =
    Element.rgb 0.12 0.14 0.15


gray10 =
    Element.rgb 0 0 0


primary =
    Element.rgb 0.05 0.43 0.99


secondary =
    gray6


success =
    Element.rgb 0.1 0.53 0.33


info =
    Element.rgb 0.05 0.79 0.94


warning =
    Element.rgb 1 0.76 0.03


danger =
    Element.rgb 0.86 0.21 0.27



-- Fonts


fontFamilyBase =
    Font.family
        [ Font.typeface "system-ui"
        , Font.typeface "-apple-system"
        , Font.typeface "Segoe UI"
        , Font.typeface "Roboto"
        , Font.typeface "Helvetica Neue"
        , Font.typeface "Arial"
        , Font.typeface "Noto Sans"
        , Font.typeface "Liberation Sans"
        , Font.sansSerif
        , Font.typeface "Apple Color Emoji"
        , Font.typeface "Segoe UI Emoji"
        , Font.typeface "Segoe UI Symbol"
        , Font.typeface "Noto Color Emoji"
        ]


fontFamilyMonospace =
    Font.family
        [ Font.typeface "SFMono-Regular"
        , Font.typeface "Menlo"
        , Font.typeface "Monaco"
        , Font.typeface "Consolas"
        , Font.typeface "Liberation Mono"
        , Font.typeface "Courier New"
        , Font.monospace
        ]

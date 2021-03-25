module Ui exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Region as Region


white =
    rgb255 255 255 255


gray100 =
    rgb255 248 249 250


gray200 =
    rgb255 233 236 239


gray300 =
    rgb255 222 226 230


gray400 =
    rgb255 206 212 218


gray500 =
    rgb255 173 181 189


gray600 =
    rgb255 108 117 125


gray700 =
    rgb255 73 80 87


gray800 =
    rgb255 52 58 64


gray900 =
    rgb255 33 37 41


black =
    rgb255 0 0 0



--


blue =
    rgb255 13 110 253


indigo =
    rgb255 102 16 242


purple =
    rgb255 111 66 193


pink =
    rgb255 214 51 132


red =
    rgb255 220 53 69


orange =
    rgb255 253 126 20


yellow =
    rgb255 255 193 7


green =
    rgb255 25 135 84


teal =
    rgb255 32 201 151


cyan =
    rgb255 13 202 240



--


primary =
    blue


secondary =
    gray600


success =
    green


info =
    cyan


warning =
    yellow


danger =
    red


light =
    gray100


dark =
    gray900



--


fontSansSerif =
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


fontMonospace =
    [ Font.typeface "SFMono-Regular"
    , Font.typeface "Menlo"
    , Font.typeface "Monaco"
    , Font.typeface "Consolas"
    , Font.typeface "Liberation Mono"
    , Font.typeface "Courier New"
    , Font.monospace
    ]



--


p a =
    paragraph (spacing 8 :: a)


h1 a =
    p (Region.heading 1 :: Font.size (16 * 2.5 |> round) :: a)


h2 a =
    p (Region.heading 2 :: Font.size (16 * 2 |> round) :: a)


h3 a =
    p (Region.heading 3 :: Font.size ((16 * 1.75) |> round) :: a)


h4 a =
    p (Region.heading 4 :: Font.size ((16 * 1.5) |> round) :: a)


h5 a =
    p (Region.heading 5 :: Font.size ((16 * 1.25) |> round) :: a)


h6 a =
    p (Region.heading 6 :: Font.size (16 |> round) :: a)



--


rootStyle =
    [ Background.color white
    , Font.color gray900
    , Font.size 16
    , Font.family fontSansSerif
    ]

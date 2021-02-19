module View.Layout exposing
    ( Layout
    , auto
    , column
    , element
    , px
    , ratio
    , ratio1
    , rem
    , render
    , renderCss
    , row
    , scroll
    )

{-| Pravdomil Layout

Inspired by elm-ui.

Note: Flex size is computed by content size, width, flex-basis (limited by min|max-width).
Note 2: Default value for min-width is auto (content width).

-}

import Html exposing (..)
import Html.Attributes exposing (class, style)


type Layout msg
    = Row Size (List (Attribute msg)) (List (Layout msg))
    | Column Size (List (Attribute msg)) (List (Layout msg))
    | Element Size (List (Attribute msg)) (Html msg)
    | Scroll Size (List (Attribute msg)) (List (Html msg))


type Size
    = Px Float
    | Rem Float
    | Ratio Float
    | Auto


type Direction
    = Row_
    | Column_



--


row =
    Row


column =
    Column


element =
    Element


scroll =
    Scroll



--


px =
    Px


rem =
    Rem


ratio =
    Ratio


ratio1 =
    Ratio 1


auto =
    Auto



--


renderCss : Html msg
renderCss =
    css


render : List (Attribute msg) -> List (Layout msg) -> Html msg
render attr a =
    div (rowClass :: attr)
        (a |> List.map helper)



--


helper : Layout msg -> Html msg
helper a =
    case a of
        Row size_ attrs b ->
            div (rowClass :: sizeToAttr size_ :: minSize Row_ b :: attrs) (b |> List.map helper)

        Column size_ attrs b ->
            div (columnClass :: sizeToAttr size_ :: minSize Column_ b :: attrs) (b |> List.map helper)

        Element size_ attrs b ->
            div (elementClass :: sizeToAttr size_ :: attrs) [ b ]

        Scroll size_ attrs b ->
            div (scrollClass :: sizeToAttr size_ :: attrs) b



--


minSize : Direction -> List (Layout msg) -> Attribute msg
minSize dir a =
    let
        toPx : Size -> Maybe Float
        toPx b =
            case b of
                Px c ->
                    Just c

                _ ->
                    Nothing

        toRem : Size -> Maybe Float
        toRem b =
            case b of
                Rem c ->
                    Just c

                _ ->
                    Nothing

        sum : (Size -> Maybe Float) -> String -> Maybe String
        sum fn suffix =
            a
                |> List.filterMap (size >> fn)
                |> List.foldl (+) 0
                |> (\v ->
                        if v == 0 then
                            Nothing

                        else
                            Just (String.fromFloat v ++ suffix)
                   )
    in
    [ sum toPx "px"
    , sum toRem "rem"
    ]
        |> List.filterMap identity
        |> String.join " + "
        |> wrapInCalc
        |> style ("min-" ++ directionToProperty dir)


sizeToAttr : Size -> Attribute msg
sizeToAttr a =
    case a of
        Px b ->
            style "flex" ("0 0 " ++ String.fromFloat b ++ "px")

        Rem b ->
            style "flex" ("0 0 " ++ String.fromFloat b ++ "rem")

        Ratio b ->
            style "flex" (String.fromFloat b ++ " 0 0%")

        Auto ->
            style "flex" "0 0 auto"


size : Layout msg -> Size
size a =
    case a of
        Row b _ _ ->
            b

        Column b _ _ ->
            b

        Element b _ _ ->
            b

        Scroll b _ _ ->
            b



--


directionToProperty : Direction -> String
directionToProperty a =
    case a of
        Row_ ->
            "width"

        Column_ ->
            "height"


wrapInCalc : String -> String
wrapInCalc a =
    "calc(" ++ a ++ ")"



--


css : Html msg
css =
    node "style"
        []
        [ text ".pl-row         { display: flex; }"
        , text ".pl-column      { display: flex; flex-direction: column; }"
        , text ".pl-element     { display: flex; }"
        , text ".pl-element > * { flex: 0 0 100%; }"
        , text ".pl-scroll      { overflow: auto; }"

        --
        , text ".pl-row, .pl-column, .pl-element, .pl-scroll { min-width: 0; min-height: 0; }"
        ]


rowClass : Attribute msg
rowClass =
    class "pl-row"


columnClass : Attribute msg
columnClass =
    class "pl-column"


elementClass : Attribute msg
elementClass =
    class "pl-element"


scrollClass : Attribute msg
scrollClass =
    class "pl-scroll"

module View.Layout exposing
    ( Layout
    , column
    , element
    , html
    , px
    , ratio
    , ratio1
    , rem
    , render
    , renderCss
    , row
    )

{-| Pravdomil Layout

Inspired by elm-ui.

Note: Flex size is computed by content size, width, flex-basis (limited by min|max-width).
Note 2: Default value for min-width is auto (content width).

-}

import Html exposing (..)
import Html.Attributes exposing (class, style)


{-| -}
type Layout msg
    = Row Size (List (Attribute msg)) (List (Layout msg))
    | Column Size (List (Attribute msg)) (List (Layout msg))
    | Element Size (List (Attribute msg)) (Html msg)
    | Html Size (List (Attribute msg)) (List (Html msg))


{-| -}
type Size
    = Px Float
    | Rem Float
    | Ratio Float


{-| -}
type Direction
    = Row_
    | Column_



--


{-| -}
row =
    Row


{-| -}
column =
    Column


{-| -}
element =
    Element


{-| -}
html =
    Html



--


{-| -}
px =
    Px


{-| -}
rem =
    Rem


{-| -}
ratio =
    Ratio


{-| -}
ratio1 =
    Ratio 1



--


{-| -}
renderCss : Html msg
renderCss =
    css


{-| -}
render : Layout msg -> Html msg
render a =
    a |> helper Column_



--


{-| -}
helper : Direction -> Layout msg -> Html msg
helper dir a =
    case a of
        Row size_ attrs b ->
            div (rowClass :: sizeToAttr dir size_ :: minSize Row_ b :: attrs) (b |> List.map (helper Row_))

        Column size_ attrs b ->
            div (columnClass :: sizeToAttr dir size_ :: minSize Column_ b :: attrs) (b |> List.map (helper Column_))

        Element size_ attrs b ->
            div (elementClass :: sizeToAttr dir size_ :: attrs) [ b ]

        Html size_ attrs b ->
            div (htmlClass :: sizeToAttr dir size_ :: attrs) b



--


{-| -}
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


{-| -}
sizeToAttr : Direction -> Size -> Attribute msg
sizeToAttr dir a =
    case a of
        Px b ->
            style (directionToProperty dir) (String.fromFloat b ++ "px")

        Rem b ->
            style (directionToProperty dir) (String.fromFloat b ++ "rem")

        Ratio b ->
            style "flex" (String.fromFloat b ++ " 0 0%")


{-| -}
size : Layout msg -> Size
size a =
    case a of
        Row b _ _ ->
            b

        Column b _ _ ->
            b

        Element b _ _ ->
            b

        Html b _ _ ->
            b



--


{-| -}
directionToProperty : Direction -> String
directionToProperty a =
    case a of
        Row_ ->
            "width"

        Column_ ->
            "height"


{-| -}
wrapInCalc : String -> String
wrapInCalc a =
    "calc(" ++ a ++ ")"



--


{-| -}
css : Html msg
css =
    node "style"
        []
        [ text ".pl-row,     .pl-column,     .pl-element     { display: flex; }"
        , text ".pl-row > *, .pl-column > *, .pl-element > * { flex: 0 0 auto; min-width: 0; min-height: 0; }"

        --
        , text ".pl-column      { flex-direction: column; }"
        , text ".pl-element > * { width: 100%; }"
        , text ".pl-html        { overflow: auto; }"
        ]


{-| -}
rowClass : Attribute msg
rowClass =
    class "pl-row"


{-| -}
columnClass : Attribute msg
columnClass =
    class "pl-column"


{-| -}
elementClass : Attribute msg
elementClass =
    class "pl-element"


{-| -}
htmlClass : Attribute msg
htmlClass =
    class "pl-html"

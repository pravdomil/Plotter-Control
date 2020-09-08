module Utils.Layout exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)
import String exposing (fromFloat)


{-| To define position constrains.
-}
type Constrain
    = -- Basics
      Top Offset
    | Bottom Offset
    | Left Offset
    | Right Offset
      -- Center
    | TopCenter Offset Offset
    | BottomCenter Offset Offset
    | LeftCenter Offset Offset
    | RightCenter Offset Offset
    | Center Offset Offset
      -- Fill
    | Fill Offset Offset Offset Offset
    | FillWidth Offset Offset
    | FillHeight Offset Offset
      -- Size
    | Width Size
    | Height Size
    | Size Size Size
      -- Raw Size
    | Width_ String
    | Height_ String
    | Size_ String String


{-| To specify offset use number in rem units.
-}
type alias Offset =
    Float


{-| To specify size use number in rem units.
-}
type alias Size =
    Float


{-| To make element to be container for floating elements.
-}
container : List Constrain -> List (Attribute msg)
container a =
    [ style "position" "relative" ] ++ (a |> List.concatMap constrainToAttributes)


{-| To make element float inside container.
-}
float : List Constrain -> List (Attribute msg)
float a =
    [ style "position" "absolute" ] ++ (a |> List.concatMap constrainToAttributes)


{-| To convert constrain to HTML attributes.
-}
constrainToAttributes : Constrain -> List (Attribute msg)
constrainToAttributes a =
    case a of
        -- Basics
        Top offset ->
            [ style "top" (offset |> toRem) ]

        Bottom offset ->
            [ style "bottom" (offset |> toRem) ]

        Left offset ->
            [ style "left" (offset |> toRem) ]

        Right offset ->
            [ style "right" (offset |> toRem) ]

        -- Center
        TopCenter offsetX offsetY ->
            [ style "top" (offsetY |> toRem), style "left" ("calc(50% - " ++ (offsetX |> toRem) ++ ")"), style "transform" "translateX(-50%)" ]

        BottomCenter offsetX offsetY ->
            [ style "bottom" (offsetY |> toRem), style "left" ("calc(50% - " ++ (offsetX |> toRem) ++ ")"), style "transform" "translateX(-50%)" ]

        LeftCenter offsetX offsetY ->
            [ style "left" (offsetX |> toRem), style "top" ("calc(50% - " ++ (offsetY |> toRem) ++ ")"), style "transform" "translateY(-50%)" ]

        RightCenter offsetX offsetY ->
            [ style "right" (offsetX |> toRem), style "top" ("calc(50% - " ++ (offsetY |> toRem) ++ ")"), style "transform" "translateY(-50%)" ]

        Center offsetX offsetY ->
            [ style "left" ("calc(50% - " ++ (offsetX |> toRem) ++ ")"), style "top" ("calc(50% - " ++ (offsetY |> toRem) ++ ")"), style "transform" "translate(-50%, -50%)" ]

        -- Fill
        Fill top right bottom left ->
            [ style "top" (top |> toRem)
            , style "right" (right |> toRem)
            , style "bottom" (bottom |> toRem)
            , style "left" (left |> toRem)
            ]

        FillWidth offsetLeft offsetRight ->
            [ style "left" (offsetLeft |> toRem), style "right" (offsetRight |> toRem) ]

        FillHeight offsetTop offsetBottom ->
            [ style "top" (offsetTop |> toRem), style "bottom" (offsetBottom |> toRem) ]

        -- Size
        Width width ->
            [ style "width" (width |> toRem) ]

        Height height ->
            [ style "height" (height |> toRem) ]

        Size width height ->
            [ style "width" (width |> toRem), style "height" (height |> toRem) ]

        -- Raw Size
        Width_ width ->
            [ style "width" width ]

        Height_ height ->
            [ style "height" height ]

        Size_ width height ->
            [ style "width" width, style "height" height ]


{-| To convert number to rem units.
-}
toRem : Float -> String
toRem a =
    a |> fromFloat |> (\v -> v ++ "rem")

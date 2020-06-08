module Utils.Rectangle exposing (PositionX(..), PositionY(..), absolute, relative)

{-| After long long journey, we have created design system, that is good enough
and is only about creating rectangles around screen.
There are only two functions we need to know: absolute and relative.
-}

import Html exposing (Attribute, Html)
import Html.Attributes exposing (style)
import String exposing (fromFloat)


{-| To specify horizontal position and width of the rectangle.

  - Fixed to the left, with offset and width.
  - Fixed to the center, with offset and width.
  - Fixed to the right, with offset and width.
  - Full width with offset from left and right.
  - Custom position and width in format: left, right, width.

-}
type PositionX
    = Left Offset Width
    | CenterX Offset Width
    | Right Offset Width
    | FillX Offset Offset
    | CustomX String String String


{-| To specify vertical position and height of the rectangle.

  - Fixed to the top, with offset and height.
  - Fixed to the center, with offset and height.
  - Fixed to the bottom, with offset and height.
  - Full height with offset from top and bottom.
  - Custom position and height in format: top, bottom, height.

-}
type PositionY
    = Top Offset Height
    | CenterY Offset Height
    | Bottom Offset Height
    | FillY Offset Offset
    | CustomY String String String


{-| To specify offset use float in rem units.
-}
type alias Offset =
    Float


{-| To specify size use float in rem units. Zero means do not set size.
-}
type alias Size =
    Float


{-| Same as size.
-}
type alias Width =
    Size


{-| Same as size.
-}
type alias Height =
    Size


{-| To position element absolute. Returns html attributes.
-}
absolute : ( PositionX, PositionY ) -> List (Attribute msg)
absolute ( w, h ) =
    let
        ( left, right, width ) =
            positionToString w

        ( top, bottom, height ) =
            positionToString (positionYToPositionX h)
    in
    [ style "position" "absolute"
    , style "left" left
    , style "right" right
    , style "width" width
    , style "top" top
    , style "bottom" bottom
    , style "height" height
    ]


{-| To position element relative. Returns html attributes.
-}
relative : ( Width, Height ) -> List (Attribute msg)
relative ( w, h ) =
    [ style "position" "relative"
    , style "width" (sizeToRem w)
    , style "height" (sizeToRem h)
    ]



-- Private Section


{-| To get left/right/width or top/bottom/height css attribute values from position.
Both axises are computed the same.
-}
positionToString : PositionX -> ( String, String, String )
positionToString a =
    case a of
        Left margin size ->
            ( toRem margin, "", sizeToRem size )

        CenterX margin size ->
            ( "calc(50% - " ++ toRem (size / 2) ++ " + " ++ toRem margin ++ ")", "", sizeToRem size )

        Right margin size ->
            ( "", toRem margin, sizeToRem size )

        FillX margin margin2 ->
            ( toRem margin, toRem margin2, "" )

        CustomX b c d ->
            ( b, c, d )


{-| To convert PositionY to PositionX. Since both axises are computed the same, we can do that.
-}
positionYToPositionX : PositionY -> PositionX
positionYToPositionX a =
    case a of
        Top b c ->
            Left b c

        CenterY b c ->
            CenterX b c

        Bottom b c ->
            Right b c

        FillY b c ->
            FillX b c

        CustomY b c d ->
            CustomX b c d


{-| To convert size to rem unit. Zero means do not set size.
-}
sizeToRem : Size -> String
sizeToRem a =
    if a == 0 then
        ""

    else
        toRem a


{-| To convert number to rem unit.
-}
toRem : Float -> String
toRem a =
    fromFloat a ++ "rem"

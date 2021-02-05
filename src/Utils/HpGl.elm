module Utils.HpGl exposing (..)

{-| -}


{-| <https://en.wikipedia.org/wiki/HP-GL>
-}
type HpGl
    = HpGl String


{-| -}
fromString : String -> HpGl
fromString =
    HpGl


{-| -}
toString : HpGl -> String
toString (HpGl a) =
    a

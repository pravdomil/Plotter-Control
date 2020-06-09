module Utils.Utils exposing (..)

{-| -}


{-| Since Cmd.batch [reverses order of commands], we have created cmd batch that
hopefully respects order of commands.

[reverses order of commands]: https://www.reddit.com/r/elm/comments/6as1re/platformcmdbatch_executes_commands_in_reverse

-}
cmdBatch : List (Cmd msg) -> Cmd msg
cmdBatch a =
    a |> List.reverse |> Cmd.batch


{-| To define what point is.
-}
type alias Point =
    ( Float, Float )


{-| To convert boolean to 0 or 1.
-}
boolToNumber : Bool -> number
boolToNumber a =
    if a then
        1

    else
        0

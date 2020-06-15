module Utils.Command exposing (..)

import String exposing (fromFloat, join)


{-| To define MGL-IIc commands.
-}
type Command
    = IN
    | IP0011
    | LineStart Float Float
    | LineTo Float Float
    | LineEnd


{-| To define plotter step size.
-}
stepSize : Float
stepSize =
    0.025


{-| To offset commands by distance.
-}
offsetBy : ( Float, Float ) -> Command -> Command
offsetBy ( offsetX, offsetY ) a =
    case a of
        LineStart x y ->
            LineStart (x + offsetX) (y + offsetY)

        LineTo x y ->
            LineTo (x + offsetX) (y + offsetY)

        _ ->
            a


{-| -}
scaleBy : ( Float, Float ) -> Command -> Command
scaleBy ( scaleX, scaleY ) a =
    case a of
        LineStart x y ->
            LineStart (x * scaleX) (y * scaleY)

        LineTo x y ->
            LineTo (x * scaleX) (y * scaleY)

        _ ->
            a


{-| To convert commands to string.
-}
commandsToString : List Command -> String
commandsToString a =
    a
        |> List.map
            (\v ->
                v
                    |> scaleBy ( 1 / stepSize, 1 / stepSize )
                    |> commandToString
            )
        |> join ";"


{-| To convert command to string.
-}
commandToString : Command -> String
commandToString a =
    case a of
        IN ->
            "IN"

        IP0011 ->
            "IP0,0,1,1"

        LineStart x y ->
            "PU" ++ fromFloat y ++ "," ++ fromFloat x

        LineTo x y ->
            "PD" ++ fromFloat y ++ "," ++ fromFloat x

        LineEnd ->
            "PU"

module Utils.Command exposing (..)

import String exposing (fromFloat, join)


{-| To define MGL-IIc commands.
-}
type Command
    = IN
    | IP0011
    | LineEnd
    | PU2 Float Float
    | PD Float Float


{-| To define plotter step size.
-}
stepSize : Float
stepSize =
    0.025


{-| To offset commands by distance in millimeters.
-}
offsetBy : ( Float, Float ) -> Command -> Command
offsetBy ( offsetY, offsetX ) a =
    case a of
        PU2 x y ->
            PU2 (x + offsetX / stepSize) (y + offsetY / stepSize)

        PD x y ->
            PD (x + offsetX / stepSize) (y + offsetY / stepSize)

        _ ->
            a


{-| To convert commands to string.
-}
commandsToString : List Command -> String
commandsToString a =
    a
        |> List.map commandToString
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

        LineEnd ->
            "PU"

        PU2 x y ->
            "PU" ++ fromFloat x ++ "," ++ fromFloat y

        PD x y ->
            "PD" ++ fromFloat x ++ "," ++ fromFloat y

port module Utils.Interop exposing (..)

import Json.Decode as Decode


{-| -}
port sendData : String -> Cmd msg


{-| -}
port statusSubscription : (Decode.Value -> msg) -> Sub msg



--


{-| -}
type Status
    = Ready
    | Connecting
    | Idle
    | Busy
    | Error String

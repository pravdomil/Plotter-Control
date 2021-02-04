port module Utils.Interop exposing (..)

import Json.Decode as Decode exposing (Decoder)


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


{-| -}
statusDecoder : Decoder Status
statusDecoder =
    Decode.field "_" Decode.int
        |> Decode.andThen
            (\i___ ->
                case i___ of
                    0 ->
                        Decode.succeed Ready

                    1 ->
                        Decode.succeed Connecting

                    2 ->
                        Decode.succeed Idle

                    3 ->
                        Decode.succeed Busy

                    4 ->
                        Decode.map Error (Decode.field "a" Decode.string)

                    _ ->
                        Decode.fail ("I can't decode " ++ "Status" ++ ", unknown variant with index " ++ String.fromInt i___ ++ ".")
            )

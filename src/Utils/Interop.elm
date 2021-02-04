port module Utils.Interop exposing (..)

import Json.Decode as Decode exposing (Decoder)


{-| -}
port sendData : String -> Cmd msg


{-| -}
port statusSubscriptionPort : (Decode.Value -> msg) -> Sub msg


{-| -}
statusSubscription : (Status -> msg) -> Sub msg
statusSubscription fn =
    let
        decode : Decode.Value -> Status
        decode a =
            case a |> Decode.decodeValue statusDecoder of
                Ok b ->
                    b

                Err b ->
                    Error (Decode.errorToString b)
    in
    statusSubscriptionPort (decode >> fn)



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

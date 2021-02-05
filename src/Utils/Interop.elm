port module Utils.Interop exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Utils.HpGl as HpGl exposing (HpGl)


{-| -}
port sendDataPort : String -> Cmd msg


{-| -}
sendData : HpGl -> Cmd msg
sendData a =
    a |> HpGl.toString |> sendDataPort



--


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
                    Error (DecodeError b)
    in
    statusSubscriptionPort (decode >> fn)



--


{-| -}
type Status
    = Ready
    | Connecting
    | Busy
    | Error Error


{-| -}
type Error
    = OpenError
    | WriterError
    | WriteError
    | DecodeError Decode.Error


{-| -}
statusDecoder : Decoder Status
statusDecoder =
    Decode.field "_" Decode.int
        |> Decode.andThen
            (\i ->
                case i of
                    0 ->
                        Decode.succeed Ready

                    1 ->
                        Decode.succeed Connecting

                    2 ->
                        Decode.succeed Busy

                    3 ->
                        Decode.map Error (Decode.field "a" errorDecoder)

                    _ ->
                        Decode.fail ("I can't decode " ++ "Status" ++ ", unknown variant with index " ++ String.fromInt i ++ ".")
            )


{-| -}
errorDecoder : Decoder Error
errorDecoder =
    Decode.field "_" Decode.int
        |> Decode.andThen
            (\i ->
                case i of
                    0 ->
                        Decode.succeed OpenError

                    1 ->
                        Decode.succeed WriterError

                    2 ->
                        Decode.succeed WriteError

                    _ ->
                        Decode.fail ("I can't decode Error, unknown variant with index " ++ String.fromInt i ++ ".")
            )

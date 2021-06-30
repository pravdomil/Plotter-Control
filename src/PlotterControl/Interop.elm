port module PlotterControl.Interop exposing (Error(..), Status(..), sendData, statusSubscription)

import Json.Decode as Decode exposing (Decoder)
import PlotterControl.Data.PlotData as PlotData exposing (PlotData)
import PlotterControl.Interop.Decode


type Status
    = Ready
    | Connecting
    | Busy
    | Error Error


type Error
    = OpenError
    | WriterError
    | WriteError
    | DecodeError String



--


port sendDataPort : String -> Cmd msg


sendData : PlotData -> Cmd msg
sendData a =
    a |> PlotData.toString |> sendDataPort



--


port statusSubscriptionPort : (Decode.Value -> msg) -> Sub msg


statusSubscription : (Status -> msg) -> Sub msg
statusSubscription fn =
    let
        decode : Decode.Value -> Status
        decode a =
            case a |> Decode.decodeValue PlotterControl.Interop.Decode.status of
                Ok b ->
                    b

                Err b ->
                    Error (DecodeError (Decode.errorToString b))
    in
    statusSubscriptionPort (decode >> fn)

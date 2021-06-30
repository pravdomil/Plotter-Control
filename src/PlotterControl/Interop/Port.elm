port module PlotterControl.Interop.Port exposing (sendData, statusSubscription)

import Json.Decode as Decode exposing (Decoder)
import PlotterControl.Data.PlotData as PlotData exposing (PlotData)
import PlotterControl.Interop.Status as Status exposing (Status)
import PlotterControl.Interop.Status.Decode


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
            case a |> Decode.decodeValue PlotterControl.Interop.Status.Decode.status of
                Ok b ->
                    b

                Err b ->
                    Status.Error (Status.DecodeError (Decode.errorToString b))
    in
    statusSubscriptionPort (decode >> fn)

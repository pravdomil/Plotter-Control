module PlotterControl.Plotter exposing (..)

import Task
import USB.Device
import WakeLock


type alias Plotter =
    USB.Device.Device


get : Task.Task Error Plotter
get =
    USB.Device.request
        [ USB.Device.Filter (Just 0x099F) (Just 0x0100) Nothing Nothing Nothing Nothing
        ]
        |> Task.mapError USBDeviceError


sendData : String -> Plotter -> Task.Task Error ()
sendData data a =
    USB.Device.open a
        |> Task.andThen (USB.Device.selectConfiguration 1)
        |> Task.andThen (USB.Device.claimInterface 0)
        |> Task.andThen (USB.Device.transferOut 1 data)
        |> Task.mapError USBDeviceError
        |> Task.map (\_ -> ())
        |> doNotSleep


stop : Plotter -> Task.Task Error ()
stop a =
    USB.Device.reset a
        |> Task.mapError USBDeviceError
        |> Task.map (\_ -> ())



--


doNotSleep : Task.Task Error a -> Task.Task Error a
doNotSleep a =
    WakeLock.acquire
        |> Task.mapError WakeLockError
        |> Task.andThen
            (\lock ->
                a
                    |> taskAndThenWithResult
                        (\v ->
                            WakeLock.release lock
                                |> Task.mapError WakeLockError
                                |> Task.andThen
                                    (\_ ->
                                        case v of
                                            Ok v2 ->
                                                Task.succeed v2

                                            Err v2 ->
                                                Task.fail v2
                                    )
                        )
            )



--


type Error
    = USBDeviceError USB.Device.Error
    | WakeLockError WakeLock.Error



--


taskAndThenWithResult : (Result x a -> Task.Task y b) -> Task.Task x a -> Task.Task y b
taskAndThenWithResult next a =
    a
        |> Task.map Ok
        |> Task.onError (Err >> Task.succeed)
        |> Task.andThen next

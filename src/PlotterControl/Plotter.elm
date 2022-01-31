module PlotterControl.Plotter exposing (..)

import Task
import Task.Extra
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
                    |> Task.Extra.taskAndThenWithResult
                        (\v ->
                            WakeLock.release lock
                                |> Task.mapError WakeLockError
                                |> Task.andThen
                                    (\_ ->
                                        Task.Extra.fromResult v
                                    )
                        )
            )



--


type Error
    = USBDeviceError USB.Device.Error
    | WakeLockError WakeLock.Error

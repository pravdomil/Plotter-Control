module PlotterControl.Plotter exposing (..)

import Task
import Task.Extra
import Usb.Device
import WakeLock


type alias Plotter =
    Usb.Device.Device


get : Task.Task Error Plotter
get =
    Usb.Device.request
        [ Usb.Device.Filter (Just 0x099F) (Just 0x0100) Nothing Nothing Nothing Nothing
        ]
        |> Task.mapError USBDeviceError


sendData : String -> Plotter -> Task.Task Error ()
sendData data a =
    Usb.Device.open a
        |> Task.andThen (Usb.Device.selectConfiguration 1)
        |> Task.andThen (Usb.Device.claimInterface 0)
        |> Task.andThen (Usb.Device.transferOut 1 data)
        |> Task.mapError USBDeviceError
        |> Task.map (\_ -> ())
        |> doNotSleep


stop : Plotter -> Task.Task Error ()
stop a =
    Usb.Device.reset a
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
                    |> Task.Extra.andAlwaysThen
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
    = USBDeviceError Usb.Device.Error
    | WakeLockError WakeLock.Error

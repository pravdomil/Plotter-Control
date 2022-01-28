module PlotterControl.SerialPort exposing (..)

import SerialPort
import Task
import WakeLock


send : String -> Task.Task Error ()
send a =
    let
        getPort : Task.Task Error SerialPort.SerialPort
        getPort =
            SerialPort.request
                |> Task.mapError SerialPortError

        getWritableStream : SerialPort.SerialPort -> Task.Task Error SerialPort.WritableStream
        getWritableStream b =
            b
                |> SerialPort.writableStream (SerialPort.defaultOptions |> (\v -> { v | baudRate = 57600 }))
                |> Task.mapError SerialPortError

        sendData : SerialPort.WritableStream -> Task.Task Error ()
        sendData b =
            WakeLock.acquire
                |> Task.mapError WakeLockError
                |> Task.andThen
                    (\lock ->
                        SerialPort.write a b
                            |> Task.mapError SerialPortError
                            |> taskAndThenWithResult
                                (\v ->
                                    WakeLock.release lock
                                        |> Task.mapError WakeLockError
                                        |> Task.andThen
                                            (\_ ->
                                                case v of
                                                    Ok _ ->
                                                        Task.succeed ()

                                                    Err v2 ->
                                                        Task.fail v2
                                            )
                                )
                    )
    in
    getPort
        |> Task.andThen getWritableStream
        |> Task.andThen sendData



--


type Error
    = SerialPortError SerialPort.Error
    | WakeLockError WakeLock.Error



--


taskAndThenWithResult : (Result x a -> Task.Task y b) -> Task.Task x a -> Task.Task y b
taskAndThenWithResult next a =
    a
        |> Task.map Ok
        |> Task.onError (Err >> Task.succeed)
        |> Task.andThen next

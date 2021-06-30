module PlotterControl.Translation exposing (..)

import PlotterControl.Interop.Status as Status exposing (Status)


raw a =
    a


title =
    "Plotter Control"



--


status : Status -> String
status a =
    case a of
        Status.Ready ->
            "Ready."

        Status.Connecting ->
            "Connecting..."

        Status.Busy ->
            "Busy..."

        Status.Error b ->
            interopError b


interopError : Status.Error -> String
interopError a =
    case a of
        Status.OpenError ->
            "Can't open serial port."

        Status.WriterError ->
            "Serial port is busy."

        Status.WriteError ->
            "Can't write data to serial port."

        Status.DecodeError _ ->
            "Can't communicate with serial port."

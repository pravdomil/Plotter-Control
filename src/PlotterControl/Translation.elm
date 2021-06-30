module PlotterControl.Translation exposing (..)

import PlotterControl.Interop exposing (Error(..), Status(..))


raw a =
    a


title =
    "Plotter Control"



--


status : Status -> String
status a =
    case a of
        Ready ->
            "Ready."

        Connecting ->
            "Connecting..."

        Busy ->
            "Busy..."

        Error b ->
            interopError b


interopError : PlotterControl.Interop.Error -> String
interopError a =
    case a of
        OpenError ->
            "Can't open serial port."

        WriterError ->
            "Serial port is busy."

        WriteError ->
            "Can't write data to serial port."

        DecodeError _ ->
            "Can't communicate with serial port."

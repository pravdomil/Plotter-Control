module PlotterControl.Translation exposing (..)

import PlotterControl.Status exposing (Status)


raw a =
    a


title =
    "Plotter Control"



--


status : Status -> String
status a =
    case a of
        PlotterControl.Status.Ready ->
            "Ready."

        PlotterControl.Status.Connecting ->
            "Connecting..."

        PlotterControl.Status.Busy ->
            "Busy..."

        PlotterControl.Status.Error b ->
            interopError b


interopError : PlotterControl.Status.Error -> String
interopError a =
    case a of
        PlotterControl.Status.OpenError ->
            "Can't open serial port."

        PlotterControl.Status.WriterError ->
            "Serial port is busy."

        PlotterControl.Status.WriteError ->
            "Can't write data to serial port."

        PlotterControl.Status.DecodeError _ ->
            "Can't communicate with serial port."

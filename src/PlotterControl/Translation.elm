module PlotterControl.Translation exposing (..)

import PlotterControl.Data.Summa as Summa
import PlotterControl.Filename as Filename exposing (Filename)
import PlotterControl.Interop.Status as Status exposing (Status)


raw a =
    a


title =
    "Plotter Control"


na =
    "n/a"



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


tool : Summa.Tool -> String
tool a =
    case a of
        Summa.Pen ->
            "Pen"

        Summa.Knife ->
            "Knife"

        Summa.Pouncer ->
            "Pouncer"


cut : Filename.Cut -> String
cut a =
    case a of
        Filename.ConstCut ->
            "Constant"

        Filename.FlexCut ->
            "Flex"


format : Filename.Format -> String
format a =
    case a of
        Filename.Dmpl ->
            "DMPL"

        Filename.HpGL ->
            "HP-GL"

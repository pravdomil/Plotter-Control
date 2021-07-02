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
            "Plotter Control is ready."

        Status.Connecting ->
            "Plotter Control is connecting..."

        Status.Sending ->
            "Plotter Control is sending data..."

        Status.Error b ->
            statusError b


statusError : Status.Error -> String
statusError a =
    case a of
        Status.OpenError ->
            "Plotter Control cannot open serial port."

        Status.WriterError ->
            "Plotter Control cannot write data to busy serial port."

        Status.WriteError ->
            "Plotter Control cannot write data to serial port."

        Status.DecodeError _ ->
            "Plotter Control cannot communicate with serial port."


tool : Summa.Tool -> String
tool a =
    case a of
        Summa.Pen ->
            "pen"

        Summa.Knife ->
            "knife"

        Summa.Pouncer ->
            "pouncer"


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

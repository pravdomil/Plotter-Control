module PlotterControl.Interop.Status exposing (..)


type Status
    = Ready
    | Connecting
    | Sending
    | Error Error


type Error
    = OpenError
    | WriterError
    | WriteError
    | DecodeError String

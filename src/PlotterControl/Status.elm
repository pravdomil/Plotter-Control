module PlotterControl.Status exposing (..)


type Status
    = Ready
    | Connecting
    | Busy
    | Error Error


type Error
    = OpenError
    | WriterError
    | WriteError
    | DecodeError String

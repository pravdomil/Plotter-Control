module Translation exposing (..)

import Interop exposing (Error(..), Status(..))


type Translation
    = A_Title
    | A_Raw String
      --
    | Status_Ready
    | Status_Connecting
    | Status_Busy
      --
    | Interop_OpenError
    | Interop_WriterError
    | Interop_WriteError
    | Interop_DecodeError


t : Translation -> String
t a =
    case a of
        A_Title ->
            "Plotter Control"

        A_Raw b ->
            b

        --
        Status_Ready ->
            "Ready."

        Status_Connecting ->
            "Connecting..."

        Status_Busy ->
            "Busy..."

        --
        Interop_OpenError ->
            "Can't open serial port."

        Interop_WriterError ->
            "Serial port is busy."

        Interop_WriteError ->
            "Can't write data to serial port."

        Interop_DecodeError ->
            "Can't communicate with serial port."



--


status : Status -> Translation
status a =
    case a of
        Ready ->
            Status_Ready

        Connecting ->
            Status_Connecting

        Busy ->
            Status_Busy

        Error b ->
            interopError b


interopError : Interop.Error -> Translation
interopError a =
    case a of
        OpenError ->
            Interop_OpenError

        WriterError ->
            Interop_WriterError

        WriteError ->
            Interop_WriteError

        DecodeError _ ->
            Interop_DecodeError

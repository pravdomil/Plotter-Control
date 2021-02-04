module Types.Messages exposing (..)

import Json.Decode as Decode


{-| To define messages we can send to outside world.
-}
type ElmMessage
    = ConnectSerialPort SerialPortFilter SerialOptions
    | SendToSerialPort JsRefSerialPort String


{-| To define messages we can receive from outside world.
-}
type JavaScriptMessage
    = GotError String
    | SerialPortUpdated SerialPortStatus


{-| To filter serial ports.
-}
type alias SerialPortFilter =
    { usbVendorId : Int
    , usbProductId : Int
    }


{-| To specify options when connecting to serial port.
-}
type alias SerialOptions =
    { baudRate : Int

    --, databits : Maybe Int
    --, stopbits : Maybe Int
    --, parity : Maybe String
    --, buffersize : Maybe Int
    --, rtscts : Maybe Bool
    }


{-| To define serial port status.
-}
type SerialPortStatus
    = Idle
    | Connecting
    | Ready JsRefSerialPort
    | Busy


{-| To keep SerialPort reference in Elm.
-}
type JsRefSerialPort
    = JsRefSerialPort Decode.Value



---


{-| To convert serial port status to Bool.
-}
portStatusToBool : SerialPortStatus -> Bool
portStatusToBool a =
    case a of
        Ready _ ->
            True

        _ ->
            False

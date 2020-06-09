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
    | SerialPortUpdated (Maybe JsRefSerialPort)


{-| To filter serial ports.
-}
type alias SerialPortFilter =
    { usbVendorId : Int
    , usbProductId : Int
    }


{-| To specify options when connecting to serial port.
-}
type alias SerialOptions =
    { baudrate : Int

    --, databits : Maybe Int
    --, stopbits : Maybe Int
    --, parity : Maybe String
    --, buffersize : Maybe Int
    --, rtscts : Maybe Bool
    }


{-| To keep SerialPort reference in Elm.
-}
type JsRefSerialPort
    = JsRefSerialPort Decode.Value

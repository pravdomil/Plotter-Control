module SerialPort exposing (..)

import JavaScript
import Json.Decode
import Json.Encode
import Task


type Port
    = Port Json.Decode.Value


listPorts : Task.Task Error (List Port)
listPorts =
    JavaScript.run
        "navigator.serial.getPorts()"
        Json.Encode.null
        (Json.Decode.list (Json.Decode.value |> Json.Decode.map Port))
        |> Task.mapError toError



--


type Error
    = NotSupported
    | JavaScriptError JavaScript.Error


toError : JavaScript.Error -> Error
toError a =
    case a of
        JavaScript.Exception "ReferenceError" _ _ ->
            NotSupported

        _ ->
            JavaScriptError a

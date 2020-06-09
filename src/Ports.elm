port module Ports exposing (javaScriptMessageSubscription, sendElmMessage)

import Generated.Types.MessagesDecode exposing (javaScriptMessageDecoder)
import Generated.Types.MessagesEncode exposing (encodeElmMessage)
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode
import Types.Messages exposing (ElmMessage, JavaScriptMessage)


{-| To send Elm message.
-}
port sendElmMessage_ : Encode.Value -> Cmd msg


{-| To send Elm message.
-}
sendElmMessage : ElmMessage -> Cmd msg
sendElmMessage a =
    a |> encodeElmMessage |> sendElmMessage_


{-| To subscribe for JavaScript messages.
-}
port javaScriptMessageSubscription_ : (Decode.Value -> msg) -> Sub msg


{-| To subscribe for JavaScript messages.
-}
javaScriptMessageSubscription : (Maybe JavaScriptMessage -> msg) -> Sub msg
javaScriptMessageSubscription toMsg =
    javaScriptMessageSubscription_ (\v -> v |> decodeValue javaScriptMessageDecoder |> Result.toMaybe |> toMsg)

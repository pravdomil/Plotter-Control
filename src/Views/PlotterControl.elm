module Views.PlotterControl exposing (Config, Model, Msg, init, publicMsg, subscriptions, update, view)

import File exposing (File)
import File.Select as Select
import Html exposing (Html, a, button, div, h3, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Languages.L as L
import Ports exposing (javaScriptMessageSubscription, sendElmMessage)
import String
import Task
import Types.PlotterControl exposing (ElmMessage(..), JavaScriptMessage(..), JsRefSerialPort, SerialOptions, SerialPortFilter)
import Utils.Rectangle exposing (PositionX(..), PositionY(..), absolute)
import Utils.RegistrationMark exposing (Command(..), offsetBy, registrationMark, toString)
import Utils.Utils exposing (Point)


{-| To define what can happen.
-}
type Msg
    = -- Outside World
      GotJavaScriptMessage (Maybe JavaScriptMessage)
      -- UI
    | ConnectToPlotter
    | SelectPlotFile
    | GotPlotFile File
    | GotPlotFileContent String
    | ToggleRegistrationMark Point
    | TogglePlotFile
    | Plot


{-| To make some messages available outside this module.
-}
publicMsg =
    {}


{-| To define things we keep.
-}
type alias Model =
    { errors : List String
    , port_ : Status JsRefSerialPort
    , plotFile : Maybe String
    , selection :
        { file : Bool
        , marks : List Point
        }
    }


{-| To define status.
-}
type Status a
    = Idle
    | Waiting
    | Ready a


{-| To define what things we need.
-}
type alias Config msg =
    { sendMsg : Msg -> msg
    }


{-| To init our view.
-}
init : Config msg -> ( Model, Cmd msg )
init _ =
    ( { errors = []
      , port_ = Idle
      , plotFile = Nothing
      , selection =
            { file = False
            , marks = []
            }
      }
    , Cmd.none
    )


{-| To update our view.
-}
update : Config msg -> Msg -> Model -> ( Model, Cmd msg )
update config msg model =
    case msg of
        GotJavaScriptMessage a ->
            case a of
                Just b ->
                    case b of
                        GotError b ->
                            ( { model | errors = b :: model.errors }, Cmd.none )

                        SerialPortUpdated c ->
                            case c of
                                Just d ->
                                    ( { model | port_ = Ready d }, Cmd.none )

                                Nothing ->
                                    ( { model | port_ = Idle }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        ConnectToPlotter ->
            ( model
            , sendElmMessage
                (ConnectSerialPort
                    (SerialPortFilter 0x0403 0x6001)
                    (SerialOptions 38400)
                )
            )

        SelectPlotFile ->
            ( model
            , Select.file [] (GotPlotFile >> config.sendMsg)
            )

        GotPlotFile a ->
            ( model
            , a |> File.toString |> Task.perform (GotPlotFileContent >> config.sendMsg)
            )

        GotPlotFileContent a ->
            ( { model | plotFile = a }, Cmd.none )


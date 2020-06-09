module Views.PlotterControl exposing (Config, Model, Msg, init, publicMsg, subscriptions, update, view)

import File exposing (File)
import File.Select as Select
import Html exposing (Html, a, button, div, h3, p, text)
import Html.Attributes exposing (class, href, target)
import Html.Events exposing (onClick)
import Languages.L as L
import Ports exposing (javaScriptMessageSubscription, sendElmMessage)
import String
import Task
import Types.PlotterControl exposing (ElmMessage(..), JavaScriptMessage(..), JsRefSerialPort, SerialOptions, SerialPortFilter)
import Utils.Rectangle exposing (PositionX(..), PositionY(..), absolute)
import Utils.RegistrationMark exposing (Command(..), offsetBy, registrationMark, toString)
import Utils.Utils exposing (Point)

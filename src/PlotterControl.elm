module PlotterControl exposing (..)

import Browser
import File
import File.Select
import HP_GL
import Json.Decode
import Length
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.SerialPort
import PlotterControl.Settings
import PlotterControl.View
import Process
import Quantity
import SummaEL
import Task


main : Program Json.Decode.Value PlotterControl.Model.Model PlotterControl.Model.Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = PlotterControl.View.view
        }



--


init : Json.Decode.Value -> ( PlotterControl.Model.Model, Cmd PlotterControl.Model.Msg )
init _ =
    ( { file = Err PlotterControl.Model.NotAsked
      , settings = PlotterControl.Settings.default
      , serialPort = Err PlotterControl.Model.Ready
      }
    , Cmd.none
    )



--


update : PlotterControl.Model.Msg -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Model.Msg )
update msg model =
    case msg of
        PlotterControl.Model.OpenFile ->
            ( model
            , File.Select.file [] PlotterControl.Model.GotFile
            )

        PlotterControl.Model.GotFile a ->
            ( { model | file = Err PlotterControl.Model.Loading }
            , Process.sleep 10
                |> Task.andThen (\() -> File.toString a)
                |> Task.perform (PlotterControl.Model.GotFileContent a)
            )

        PlotterControl.Model.GotFileContent a b ->
            ( { model | file = PlotterControl.File.fromFile a b |> Result.mapError PlotterControl.Model.FileError }
            , Cmd.none
            )

        PlotterControl.Model.DragOver ->
            ( model
            , Cmd.none
            )

        PlotterControl.Model.TestMarkers ->
            case model.file of
                Ok b ->
                    ( { model | serialPort = Err PlotterControl.Model.Sending }
                    , ([ model.settings |> PlotterControl.Settings.toCommands |> Tuple.first |> SummaEL.toString
                       , b |> PlotterControl.File.toCommands |> Tuple.first |> SummaEL.toString
                       ]
                        |> String.join "\n"
                      )
                        |> PlotterControl.SerialPort.send
                        |> Task.attempt PlotterControl.Model.FileSent
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

        PlotterControl.Model.ChangePreset a ->
            let
                nextModel : PlotterControl.Model.Model
                nextModel =
                    { model
                        | settings = model.settings |> (\v -> { v | preset = a })
                    }
            in
            ( nextModel
            , nextModel.settings
                |> PlotterControl.Settings.toCommands
                |> Tuple.first
                |> SummaEL.toString
                |> PlotterControl.SerialPort.send
                |> Task.attempt PlotterControl.Model.FileSent
            )

        PlotterControl.Model.PlusCopies a ->
            ( { model
                | settings =
                    (\v -> { v | copies = v.copies |> PlotterControl.Settings.copiesPlus a }) model.settings
              }
            , Cmd.none
            )

        PlotterControl.Model.PlusCopyDistance a ->
            ( { model
                | settings =
                    (\v -> { v | copyDistance = v.copyDistance |> Quantity.plus a |> Quantity.max (Length.millimeters 0) }) model.settings
              }
            , Cmd.none
            )

        PlotterControl.Model.ChangeMarkerLoading a ->
            ( { model
                | settings =
                    model.settings |> (\v -> { v | markerLoading = a })
              }
            , Cmd.none
            )

        PlotterControl.Model.SendFile ->
            case model.file of
                Ok b ->
                    ( { model | serialPort = Err PlotterControl.Model.Sending }
                    , (let
                        ( v, v2 ) =
                            model.settings |> PlotterControl.Settings.toCommands

                        ( v3, v4 ) =
                            b |> PlotterControl.File.toCommands
                       in
                       [ v |> SummaEL.toString
                       , v3 |> SummaEL.toString
                       , v4 |> HP_GL.toString
                       , v2 |> SummaEL.toString
                       ]
                        |> String.join "\n"
                      )
                        |> PlotterControl.SerialPort.send
                        |> Task.attempt PlotterControl.Model.FileSent
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

        PlotterControl.Model.FileSent a ->
            ( { model | serialPort = a |> Result.mapError PlotterControl.Model.SerialPortError }
            , Cmd.none
            )



--


subscriptions : PlotterControl.Model.Model -> Sub PlotterControl.Model.Msg
subscriptions _ =
    Sub.none

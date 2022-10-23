module PlotterControl.Model.Update exposing (..)

import File
import File.Select
import HpGl
import Json.Decode
import Length
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter
import PlotterControl.Settings
import Process
import Quantity
import SummaEl
import Task


init : Json.Decode.Value -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
init _ =
    ( { file = Err PlotterControl.Model.NotAsked
      , settings = PlotterControl.Settings.default
      , plotter = Err PlotterControl.Model.Ready
      }
    , Cmd.none
    )



--


update : PlotterControl.Msg.Msg -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
update msg model =
    case msg of
        PlotterControl.Msg.OpenFile ->
            ( model
            , File.Select.file [] PlotterControl.Msg.GotFile
            )

        PlotterControl.Msg.GotFile a ->
            ( { model | file = Err PlotterControl.Model.Loading }
            , Process.sleep 10
                |> Task.andThen (\() -> File.toString a)
                |> Task.perform (PlotterControl.Msg.GotFileContent a)
            )

        PlotterControl.Msg.GotFileContent a b ->
            ( { model | file = PlotterControl.File.fromFile a b |> Result.mapError PlotterControl.Model.FileError }
            , Cmd.none
            )

        PlotterControl.Msg.DragOver ->
            ( model
            , Cmd.none
            )

        PlotterControl.Msg.TestMarkers ->
            ( model
            , case model.file of
                Ok b ->
                    ([ model.settings |> PlotterControl.Settings.toCommands |> Tuple.first |> SummaEl.toString
                     , b |> PlotterControl.File.toCommands |> Tuple.first |> SummaEl.toString
                     ]
                        |> String.join "\n"
                    )
                        |> PlotterControl.Msg.SendData
                        |> Platform.Extra.sendMsg

                Err _ ->
                    Cmd.none
            )

        PlotterControl.Msg.ChangePreset a ->
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
                |> SummaEl.toString
                |> PlotterControl.Msg.SendData
                |> Platform.Extra.sendMsg
            )

        PlotterControl.Msg.PlusCopies a ->
            ( { model
                | settings =
                    (\v -> { v | copies = v.copies |> PlotterControl.Settings.copiesPlus a }) model.settings
              }
            , Cmd.none
            )

        PlotterControl.Msg.PlusCopyDistance a ->
            ( { model
                | settings =
                    (\v -> { v | copyDistance = v.copyDistance |> Quantity.plus a |> Quantity.max (Length.millimeters 0) }) model.settings
              }
            , Cmd.none
            )

        PlotterControl.Msg.ChangeMarkerLoading a ->
            ( { model
                | settings =
                    model.settings |> (\v -> { v | markerLoading = a })
              }
            , Cmd.none
            )

        PlotterControl.Msg.SendFile ->
            ( model
            , case model.file of
                Ok b ->
                    let
                        ( v, v2 ) =
                            model.settings |> PlotterControl.Settings.toCommands

                        ( v3, v4 ) =
                            b |> PlotterControl.File.toCommands
                    in
                    [ v |> SummaEl.toString
                    , v3 |> SummaEl.toString
                    , v4 |> HpGl.toString
                    , v2 |> SummaEl.toString
                    ]
                        |> String.join "\n"
                        |> PlotterControl.Msg.SendData
                        |> Platform.Extra.sendMsg

                Err _ ->
                    Cmd.none
            )

        PlotterControl.Msg.SendData a ->
            ( { model | plotter = Err PlotterControl.Model.Connecting }
            , PlotterControl.Plotter.get
                |> Task.attempt (PlotterControl.Msg.GotPlotterSendData a)
            )

        PlotterControl.Msg.GotPlotterSendData a b ->
            case b of
                Ok c ->
                    ( { model | plotter = Ok c }
                    , PlotterControl.Plotter.sendData a c
                        |> Task.attempt PlotterControl.Msg.DataSent
                    )

                Err c ->
                    ( { model | plotter = Err (c |> PlotterControl.Model.PlotterError) }
                    , Cmd.none
                    )

        PlotterControl.Msg.DataSent a ->
            let
                plotter : Result PlotterControl.Model.PlotterError PlotterControl.Plotter.Plotter
                plotter =
                    case a of
                        Ok _ ->
                            Err PlotterControl.Model.FileSent

                        Err b ->
                            Err (b |> PlotterControl.Model.PlotterError)
            in
            ( { model | plotter = plotter }
            , Cmd.none
            )

        PlotterControl.Msg.StopSending ->
            ( model
            , case model.plotter of
                Ok b ->
                    PlotterControl.Plotter.stop b
                        |> Task.attempt PlotterControl.Msg.SendingStopped

                Err _ ->
                    Cmd.none
            )

        PlotterControl.Msg.SendingStopped _ ->
            ( model
            , Cmd.none
            )



--


subscriptions : PlotterControl.Model.Model -> Sub PlotterControl.Msg.Msg
subscriptions _ =
    Sub.none
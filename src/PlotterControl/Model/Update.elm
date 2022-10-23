module PlotterControl.Model.Update exposing (..)

import File
import File.Select
import HpGl
import Json.Decode
import Length
import Platform.Extra
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter
import PlotterControl.Plotter.Utils
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
        PlotterControl.Msg.NothingHappened ->
            Platform.Extra.noOperation model

        PlotterControl.Msg.OpenFileRequested ->
            ( model
            , File.Select.file [] PlotterControl.Msg.FileReceived
            )

        PlotterControl.Msg.FileReceived a ->
            ( { model | file = Err PlotterControl.Model.Loading }
            , Process.sleep 10
                |> Task.andThen (\() -> File.toString a)
                |> Task.perform (PlotterControl.Msg.FileContentReceived a)
            )

        PlotterControl.Msg.FileContentReceived a b ->
            ( { model | file = PlotterControl.File.fromFile a b |> Result.mapError PlotterControl.Model.FileError }
            , Cmd.none
            )

        PlotterControl.Msg.MarkerTestRequested ->
            case model.file of
                Ok b ->
                    let
                        data : String
                        data =
                            [ model.settings |> PlotterControl.Settings.toCommands |> Tuple.first |> SummaEl.toString
                            , b |> PlotterControl.File.toCommands |> Tuple.first |> SummaEl.toString
                            ]
                                |> String.join "\n"
                    in
                    PlotterControl.Plotter.Utils.sendData data model

                Err _ ->
                    Platform.Extra.noOperation model

        PlotterControl.Msg.PresetChanged a ->
            ( { model
                | settings = model.settings |> (\x -> { x | preset = a })
              }
            , Cmd.none
            )
                |> Platform.Extra.andThen
                    (\x ->
                        PlotterControl.Plotter.Utils.sendData
                            (x.settings |> PlotterControl.Settings.toCommands |> Tuple.first |> SummaEl.toString)
                            x
                    )

        PlotterControl.Msg.CopiesChanged a ->
            ( { model
                | settings =
                    (\x -> { x | copies = x.copies |> PlotterControl.Settings.copiesPlus a }) model.settings
              }
            , Cmd.none
            )

        PlotterControl.Msg.CopyDistanceChanged a ->
            ( { model
                | settings =
                    (\x -> { x | copyDistance = x.copyDistance |> Quantity.plus a |> Quantity.max (Length.millimeters 0) }) model.settings
              }
            , Cmd.none
            )

        PlotterControl.Msg.MarkerLoadingChanged a ->
            ( { model
                | settings =
                    model.settings |> (\x -> { x | markerLoading = a })
              }
            , Cmd.none
            )

        PlotterControl.Msg.SendFileRequested ->
            case model.file of
                Ok b ->
                    let
                        ( x, x2 ) =
                            model.settings |> PlotterControl.Settings.toCommands

                        ( x3, x4 ) =
                            b |> PlotterControl.File.toCommands

                        data : String
                        data =
                            String.join "\n"
                                [ x |> SummaEl.toString
                                , x3 |> SummaEl.toString
                                , x4 |> HpGl.toString
                                , x2 |> SummaEl.toString
                                ]
                    in
                    PlotterControl.Plotter.Utils.sendData data model

                Err _ ->
                    Platform.Extra.noOperation model

        PlotterControl.Msg.PlotterReceived a b ->
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

        PlotterControl.Msg.StopSendingRequested ->
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

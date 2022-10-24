module PlotterControl.Plotter.Update exposing (..)

import Dict.Any
import Id
import Platform.Extra
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter
import PlotterControl.Queue
import Task
import Time


sendQueue : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
sendQueue model =
    case model.plotter of
        Ok _ ->
            sendNextItemInQueue model

        Err PlotterControl.Model.NoPlotter ->
            connect model

        Err (PlotterControl.Model.PlotterError _) ->
            connect model

        _ ->
            Platform.Extra.noOperation model


connect : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
connect model =
    ( { model | plotter = Err PlotterControl.Model.PlotterConnecting }
    , PlotterControl.Plotter.connect
        |> Task.attempt PlotterControl.Msg.PlotterConnected
    )


plotterConnected : Result PlotterControl.Plotter.Error PlotterControl.Plotter.Plotter -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
plotterConnected a model =
    ( { model | plotter = Result.mapError PlotterControl.Model.PlotterError a }
    , Cmd.none
    )
        |> Platform.Extra.andThen sendNextItemInQueue


sendNextItemInQueue : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
sendNextItemInQueue model =
    case model.plotter of
        Ok a ->
            let
                nextItem : Maybe ( Id.Id PlotterControl.Queue.Item, PlotterControl.Queue.Item )
                nextItem =
                    model.queue
                        |> Dict.Any.toList
                        |> List.sortBy (\( _, x ) -> x.created |> Time.posixToMillis)
                        |> List.head
            in
            case nextItem of
                Just ( id, b ) ->
                    ( { model | plotter = Err (PlotterControl.Model.PlotterSending a) }
                    , PlotterControl.Plotter.send b.data a
                        |> Task.attempt (PlotterControl.Msg.QueueItemSent a id)
                    )

                Nothing ->
                    Platform.Extra.noOperation model

        Err _ ->
            Platform.Extra.noOperation model


queueItemSent : PlotterControl.Plotter.Plotter -> Id.Id PlotterControl.Queue.Item -> Result PlotterControl.Plotter.Error () -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
queueItemSent plotter id a model =
    (case a of
        Ok () ->
            ( { model
                | queue = Dict.Any.remove Id.toString id model.queue
                , plotter = Ok plotter
              }
            , Cmd.none
            )

        Err b ->
            ( { model | plotter = Err (PlotterControl.Model.PlotterError b) }
            , Cmd.none
            )
    )
        |> Platform.Extra.andThen sendNextItemInQueue


stopPlotter : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
stopPlotter model =
    case model.plotter of
        Err (PlotterControl.Model.PlotterSending b) ->
            ( model
            , PlotterControl.Plotter.stop b
                |> Task.attempt PlotterControl.Msg.SendingStopped
            )

        _ ->
            Platform.Extra.noOperation model

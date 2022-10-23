module PlotterControl.Queue.Update exposing (..)

import Dict.Any
import Id
import Id.Random
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter.Update
import PlotterControl.Queue
import Task


createItem : PlotterControl.Queue.ItemName -> String -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
createItem name data model =
    ( model
    , Task.map2 Tuple.pair
        Id.Random.generate
        (PlotterControl.Queue.createItem name data)
        |> Task.perform PlotterControl.Msg.QueueItemReceived
    )


addItemToQueue : ( Id.Id PlotterControl.Queue.Item, PlotterControl.Queue.Item ) -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
addItemToQueue ( id, a ) model =
    ( { model | queue = Dict.Any.insert Id.toString id a model.queue }
    , Cmd.none
    )


sendQueue : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
sendQueue model =
    PlotterControl.Plotter.Update.connect model


removeItemFromQueue : Id.Id PlotterControl.Queue.Item -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
removeItemFromQueue a model =
    ( { model | queue = Dict.Any.remove Id.toString a model.queue }
    , Cmd.none
    )

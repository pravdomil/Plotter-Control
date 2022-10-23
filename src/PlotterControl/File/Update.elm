module PlotterControl.File.Update exposing (..)

import File
import File.Select
import HpGl
import Platform.Extra
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Plotter.Utils
import PlotterControl.Settings
import Process
import SummaEl
import Task


openFile : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
openFile model =
    ( model
    , File.Select.file [] PlotterControl.Msg.FileReceived
    )


fileReceived : File.File -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
fileReceived a model =
    ( { model | file = Err PlotterControl.Model.Loading }
    , Process.sleep 10
        |> Task.andThen (\() -> File.toString a)
        |> Task.perform (PlotterControl.Msg.FileContentReceived a)
    )


fileContentReceived : File.File -> String -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
fileContentReceived a b model =
    ( { model | file = PlotterControl.File.fromFile a b |> Result.mapError PlotterControl.Model.FileError }
    , Cmd.none
    )


testMarkers : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
testMarkers model =
    case model.file of
        Ok b ->
            let
                data : String
                data =
                    [ model.settings |> PlotterControl.Settings.toCommands |> .start |> SummaEl.toString
                    , b |> PlotterControl.File.toCommands |> Tuple.first |> SummaEl.toString
                    ]
                        |> String.join "\n"
            in
            PlotterControl.Plotter.Utils.sendData data model

        Err _ ->
            Platform.Extra.noOperation model


sendFile : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
sendFile model =
    case model.file of
        Ok b ->
            let
                x =
                    model.settings |> PlotterControl.Settings.toCommands

                ( x3, x4 ) =
                    b |> PlotterControl.File.toCommands

                data : String
                data =
                    String.join "\n"
                        [ x.start |> SummaEl.toString
                        , x3 |> SummaEl.toString
                        , x4 |> HpGl.toString
                        , x.end |> SummaEl.toString
                        ]
            in
            PlotterControl.Plotter.Utils.sendData data model

        Err _ ->
            Platform.Extra.noOperation model

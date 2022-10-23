module PlotterControl.Directory.Update exposing (..)

import Dict.Any
import File
import File.Select
import List.Extra
import PlotterControl.Directory
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import Task


openFiles : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
openFiles model =
    ( model
    , File.Select.files [] (\x x2 -> PlotterControl.Msg.RawFilesReceived (x :: x2))
    )


rawFilesReceived : List File.File -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
rawFilesReceived a model =
    ( model
    , a
        |> List.reverse
        |> List.map
            (\x ->
                x
                    |> PlotterControl.File.fromFile
                    |> Task.map (Tuple.pair (PlotterControl.File.stringToName (File.name x)))
            )
        |> Task.sequence
        |> Task.perform PlotterControl.Msg.FilesReceived
    )


filesReceived : List ( PlotterControl.File.Name, PlotterControl.File.File ) -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
filesReceived a model =
    let
        files : Dict.Any.Dict PlotterControl.File.Name PlotterControl.File.File
        files =
            model.directory
                |> Result.map .files
                |> Result.withDefault Dict.Any.empty

        directory : PlotterControl.Directory.Directory
        directory =
            PlotterControl.Directory.Directory
                (a |> List.foldl (\( k, v ) -> Dict.Any.insert PlotterControl.File.nameToString k v) files)
                (a |> List.Extra.last |> Maybe.map Tuple.first)
    in
    ( { model | directory = Ok directory }
    , Cmd.none
    )


activateFile : PlotterControl.File.Name -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
activateFile name model =
    ( { model | directory = Result.map (\x -> { x | active = Just name }) model.directory }
    , Cmd.none
    )

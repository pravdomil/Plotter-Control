module PlotterControl.Directory.Utils exposing (..)

import Dict.Any
import PlotterControl.File
import PlotterControl.Model


fileByName : PlotterControl.File.Name -> PlotterControl.Model.Model -> Maybe PlotterControl.File.File
fileByName name model =
    model.directory
        |> Result.toMaybe
        |> Maybe.andThen
            (\x ->
                x.files |> Dict.Any.get PlotterControl.File.nameToString name
            )


readyFileByName : PlotterControl.File.Name -> PlotterControl.Model.Model -> Maybe ( PlotterControl.File.File, PlotterControl.File.Ready )
readyFileByName name model =
    fileByName name model
        |> Maybe.andThen
            (\x ->
                x.ready |> Result.toMaybe |> Maybe.map (Tuple.pair x)
            )


activeFile : PlotterControl.Model.Model -> Maybe ( PlotterControl.File.Name, PlotterControl.File.File )
activeFile model =
    Maybe.map2
        (\x x2 ->
            Dict.Any.get PlotterControl.File.nameToString x2 x.files
                |> Maybe.map (Tuple.pair x2)
        )
        (Result.toMaybe model.directory)
        (case model.page of
            Just (PlotterControl.Model.File x) ->
                Just x

            _ ->
                Nothing
        )
        |> Maybe.andThen identity

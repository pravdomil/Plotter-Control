module PlotterControl.Directory.Update exposing (..)

import Dict.Any
import File
import File.Select
import List.Extra
import PlotterControl.Directory
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Page
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
        |> List.map PlotterControl.File.fromFile
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
                (a |> List.foldl (\( k, v ) -> Dict.Any.update PlotterControl.File.nameToString k (fileUpdate v)) files)

        fileUpdate : PlotterControl.File.File -> Maybe PlotterControl.File.File -> Maybe PlotterControl.File.File
        fileUpdate new old =
            case old of
                Just old_ ->
                    Just
                        { new
                            | ready =
                                Result.map2
                                    (\x x2 ->
                                        { x
                                            | settings = x2.settings
                                            , markers = Maybe.map2 (\x3 x4 -> { x3 | loading = x4.loading }) x x2
                                        }
                                    )
                                    new.ready
                                    old_.ready
                        }

                Nothing ->
                    Just new

        nextPage : Maybe PlotterControl.Page.Page
        nextPage =
            case List.Extra.last a of
                Just ( name, _ ) ->
                    Just (PlotterControl.Page.File_ (PlotterControl.Page.File name))

                Nothing ->
                    model.page
    in
    ( { model
        | page = nextPage
        , directory = Ok directory
      }
    , Cmd.none
    )


activateFile : PlotterControl.File.Name -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
activateFile name model =
    ( { model | page = Just (PlotterControl.Page.File_ (PlotterControl.Page.File name)) }
    , Cmd.none
    )

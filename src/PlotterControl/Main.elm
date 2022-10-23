module PlotterControl.Main exposing (..)

import Browser
import File
import File.Select
import HpGl
import Json.Decode
import Length
import Platform.Extra
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Plotter
import PlotterControl.Settings
import PlotterControl.View
import Process
import Quantity
import SummaEl
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
      , plotter = Err PlotterControl.Model.Ready
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
            ( model
            , case model.file of
                Ok b ->
                    ([ model.settings |> PlotterControl.Settings.toCommands |> Tuple.first |> SummaEl.toString
                     , b |> PlotterControl.File.toCommands |> Tuple.first |> SummaEl.toString
                     ]
                        |> String.join "\n"
                    )
                        |> PlotterControl.Model.SendData
                        |> Platform.Extra.sendMsg

                Err _ ->
                    Cmd.none
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
                |> SummaEl.toString
                |> PlotterControl.Model.SendData
                |> Platform.Extra.sendMsg
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
                        |> PlotterControl.Model.SendData
                        |> Platform.Extra.sendMsg

                Err _ ->
                    Cmd.none
            )

        PlotterControl.Model.SendData a ->
            ( { model | plotter = Err PlotterControl.Model.Connecting }
            , PlotterControl.Plotter.get
                |> Task.attempt (PlotterControl.Model.GotPlotterSendData a)
            )

        PlotterControl.Model.GotPlotterSendData a b ->
            case b of
                Ok c ->
                    ( { model | plotter = Ok c }
                    , PlotterControl.Plotter.sendData a c
                        |> Task.attempt PlotterControl.Model.DataSent
                    )

                Err c ->
                    ( { model | plotter = Err (c |> PlotterControl.Model.PlotterError) }
                    , Cmd.none
                    )

        PlotterControl.Model.DataSent a ->
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

        PlotterControl.Model.StopSending ->
            ( model
            , case model.plotter of
                Ok b ->
                    PlotterControl.Plotter.stop b
                        |> Task.attempt PlotterControl.Model.SendingStopped

                Err _ ->
                    Cmd.none
            )

        PlotterControl.Model.SendingStopped _ ->
            ( model
            , Cmd.none
            )



--


subscriptions : PlotterControl.Model.Model -> Sub PlotterControl.Model.Msg
subscriptions _ =
    Sub.none

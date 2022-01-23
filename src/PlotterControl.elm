module PlotterControl exposing (..)

import Browser
import File
import File.Select
import Json.Decode
import Length
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Settings
import PlotterControl.View
import Quantity
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
      , serialPort = Err PlotterControl.Model.NotAsked_
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
            , File.toString a
                |> Task.perform (PlotterControl.Model.GotFileContent a)
            )

        PlotterControl.Model.GotFileContent a _ ->
            let
                file : PlotterControl.File.File
                file =
                    { name = a |> File.name |> PlotterControl.File.Name
                    , data = Ok ()
                    }
            in
            ( { model | file = Ok file }
            , Cmd.none
            )

        PlotterControl.Model.DragOver ->
            ( model
            , Cmd.none
            )

        PlotterControl.Model.ChangePreset a ->
            ( { model
                | settings =
                    (\v -> { v | preset = a }) model.settings
              }
            , Cmd.none
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



--


subscriptions : PlotterControl.Model.Model -> Sub PlotterControl.Model.Msg
subscriptions _ =
    Sub.none

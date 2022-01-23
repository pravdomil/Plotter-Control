module PlotterControl exposing (..)

import Browser
import File
import Json.Decode
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.View
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
      , serialPort = Err PlotterControl.Model.NotAsked_
      }
    , Cmd.none
    )



--


update : PlotterControl.Model.Msg -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Model.Msg )
update msg model =
    case msg of
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



--


subscriptions : PlotterControl.Model.Model -> Sub PlotterControl.Model.Msg
subscriptions _ =
    Sub.none

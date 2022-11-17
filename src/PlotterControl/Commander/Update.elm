module PlotterControl.Commander.Update exposing (..)

import PlotterControl.Commander
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Queue
import PlotterControl.Queue.Update


init : PlotterControl.Commander.Commander
init =
    PlotterControl.Commander.Commander
        PlotterControl.Commander.Raw
        ""


changeCommandType : PlotterControl.Commander.CommandType -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeCommandType a model =
    ( { model | commander = (\x -> { x | type_ = a }) model.commander }
    , Cmd.none
    )


changeCommand : String -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeCommand a model =
    ( { model | commander = (\x -> { x | command = a }) model.commander }
    , Cmd.none
    )


sendCommand : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
sendCommand model =
    let
        command : String
        command =
            model.commander.command

        data : String
        data =
            command
                |> (\x ->
                        case model.commander.type_ of
                            PlotterControl.Commander.Raw ->
                                x

                            PlotterControl.Commander.SummaEncapsulatedLanguage ->
                                "\u{001B};@:\n" ++ x ++ "\nEND\n"
                   )
    in
    PlotterControl.Queue.Update.createItem
        (PlotterControl.Queue.stringToItemName ("Commander (" ++ command ++ ")"))
        data
        model

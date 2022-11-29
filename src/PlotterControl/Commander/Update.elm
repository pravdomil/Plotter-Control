module PlotterControl.Commander.Update exposing (..)

import Dict
import Length
import PlotterControl.Commander
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Queue
import PlotterControl.Queue.Update
import Quantity
import SummaEl


init : PlotterControl.Commander.Commander
init =
    PlotterControl.Commander.Commander
        PlotterControl.Commander.Raw
        ""
        (Length.millimeters 386)
        (Length.millimeters 406.8)


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


changeSensorLeftOffset : Length.Length -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeSensorLeftOffset a model =
    ( { model | commander = (\x -> { x | sensorLeftOffset = x.sensorLeftOffset |> Quantity.plus a }) model.commander }
    , Cmd.none
    )


changeSensorUpOffset : Length.Length -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeSensorUpOffset a model =
    ( { model | commander = (\x -> { x | sensorUpOffset = x.sensorUpOffset |> Quantity.plus a }) model.commander }
    , Cmd.none
    )


calibrateSensor : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
calibrateSensor model =
    let
        lengthToString : Length.Length -> String
        lengthToString a =
            a
                |> Quantity.at resolution
                |> Quantity.toFloat
                |> round
                |> String.fromInt

        resolution : Quantity.Quantity Float (Quantity.Rate Quantity.Unitless Length.Meters)
        resolution =
            Quantity.rate (Quantity.float 80) (Length.millimeters 1)

        command : SummaEl.Command
        command =
            SummaEl.SetSystemSettings
                (Dict.empty
                    |> Dict.insert "OPOS_xoffset" (lengthToString model.commander.sensorUpOffset)
                    |> Dict.insert "OPOS_yoffset" (lengthToString model.commander.sensorLeftOffset)
                )
    in
    PlotterControl.Queue.Update.createItem
        (PlotterControl.Queue.stringToItemName "Marker Sensor Calibration")
        (SummaEl.toString [ command ])
        model

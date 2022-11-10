module PlotterControl.Checklist.Update exposing (..)

import Dict
import Dict.Any
import Platform.Extra
import PlotterControl.Checklist
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Page
import PlotterControl.Queue
import PlotterControl.Queue.Update
import SummaEl


activateChecklist : PlotterControl.Checklist.Checklist -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
activateChecklist a model =
    ( { model | page = Just (PlotterControl.Page.Checklist_ (PlotterControl.Page.Checklist a)) }
    , Cmd.none
    )


checkItem : PlotterControl.Checklist.Item -> Bool -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
checkItem item checked model =
    ( { model
        | checklist =
            if checked then
                Dict.Any.insert PlotterControl.Checklist.itemToComparable item () model.checklist

            else
                Dict.Any.remove PlotterControl.Checklist.itemToComparable item model.checklist
      }
    , Cmd.none
    )


resetChecklist : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
resetChecklist model =
    ( { model | checklist = Dict.Any.empty }
    , Cmd.none
    )


changeMarkerInsensitivity : Int -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeMarkerInsensitivity a model =
    let
        value : Int
        value =
            case model.markerInsensitivity of
                Just b ->
                    b + a

                Nothing ->
                    60
    in
    ( { model | markerInsensitivity = Just value }
    , Cmd.none
    )
        |> Platform.Extra.andThen
            (PlotterControl.Queue.Update.createItem
                (PlotterControl.Queue.stringToItemName "Set Insensitivity")
                (SummaEl.toString
                    [ SummaEl.SetSettings (Dict.singleton "OPOS_LEVEL" (String.fromInt value))
                    ]
                )
            )


testMarkers : PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
testMarkers model =
    PlotterControl.Queue.Update.createItem
        (PlotterControl.Queue.stringToItemName "Marker Test")
        (SummaEl.toString [ SummaEl.LoadMarkers ])
        model


changeDrawingSpeed : Int -> PlotterControl.Model.Model -> ( PlotterControl.Model.Model, Cmd PlotterControl.Msg.Msg )
changeDrawingSpeed a model =
    let
        value : Int
        value =
            case model.drawingSpeed of
                Just b ->
                    b + a

                Nothing ->
                    200
    in
    ( { model | drawingSpeed = Just value }
    , Cmd.none
    )
        |> Platform.Extra.andThen
            (PlotterControl.Queue.Update.createItem
                (PlotterControl.Queue.stringToItemName "Set Speed")
                (SummaEl.toString
                    [ SummaEl.SetSettings (Dict.singleton "VELOCITY" (String.fromInt value))
                    ]
                )
            )

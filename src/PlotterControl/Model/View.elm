module PlotterControl.Model.View exposing (..)

import Browser
import Element.PravdomilUi exposing (..)
import File
import Html.Events
import Json.Decode
import PlotterControl.Checklist.View
import PlotterControl.Directory.View
import PlotterControl.File.View
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Queue.View
import PlotterControl.Utils.Theme exposing (..)


view : PlotterControl.Model.Model -> Browser.Document PlotterControl.Msg.Msg
view model =
    { title = "Plotter Control"
    , body =
        [ layout theme [ width fill, height fill ] (lazy viewColumns model)
        ]
    }



--


viewColumns : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
viewColumns model =
    let
        separator : Element msg
        separator =
            el [ height fill, borderWidthEach 1 0 0 0, borderColor style.back50 ] none
    in
    row
        [ width fill
        , height fill
        , onDragOver PlotterControl.Msg.NothingHappened
        , onDrop PlotterControl.Msg.RawFilesReceived
        ]
        ([ PlotterControl.Directory.View.view model
         , PlotterControl.File.View.view model
         , PlotterControl.Queue.View.view model
         , PlotterControl.Checklist.View.view model
         ]
            |> List.map (\x -> el [ width fill, height fill, scrollbars ] x)
            |> List.intersperse separator
        )



--


onDragOver : msg -> Attribute msg
onDragOver msg =
    Html.Events.preventDefaultOn
        "dragover"
        (Json.Decode.succeed ( msg, True ))
        |> htmlAttribute


onDrop : (List File.File -> msg) -> Attribute msg
onDrop msg =
    Html.Events.preventDefaultOn
        "drop"
        (Json.Decode.at [ "dataTransfer", "files" ] (Json.Decode.list File.decoder)
            |> Json.Decode.map (\x -> ( msg x, True ))
        )
        |> htmlAttribute

module PlotterControl.Model.View exposing (..)

import Browser
import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
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
    let
        ( attrs, body ) =
            Element.PravdomilUi.Application.view
                (Element.PravdomilUi.Application.Config
                    style
                    theme
                    model.viewportSize
                    (viewColumns model)
                    []
                    Nothing
                    Nothing
                    Nothing
                    (always PlotterControl.Msg.NothingHappened)
                    PlotterControl.Msg.NothingHappened
                    PlotterControl.Msg.NothingHappened
                )
    in
    { title = "Plotter Control"
    , body =
        [ layout theme
            (onDragOver PlotterControl.Msg.NothingHappened
                :: onDrop PlotterControl.Msg.RawFilesReceived
                :: attrs
            )
            body
        ]
    }



--


viewColumns : PlotterControl.Model.Model -> List (Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg)
viewColumns model =
    [ PlotterControl.Directory.View.view model
    , PlotterControl.File.View.view model
    , PlotterControl.Queue.View.view model
    , PlotterControl.Checklist.View.view model
    ]



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

module PlotterControl.Model.View exposing (..)

import Browser
import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import File
import Html.Events
import Json.Decode
import PlotterControl.Checklist.View
import PlotterControl.File.View
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Navigation.View
import PlotterControl.Page
import PlotterControl.Queue.View
import PlotterControl.Tool.View
import PlotterControl.Utils.Theme exposing (..)


view : PlotterControl.Model.Model -> Browser.Document PlotterControl.Msg.Msg
view model =
    let
        config : Element.PravdomilUi.Application.Config PlotterControl.Msg.Msg
        config =
            Element.PravdomilUi.Application.Config
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
    in
    Browser.Document
        "Plotter Control"
        [ Element.PravdomilUi.Application.toHtml
            config
            [ onDragOver PlotterControl.Msg.NothingHappened
            , onDrop PlotterControl.Msg.RawFilesReceived
            ]
        ]



--


viewColumns : PlotterControl.Model.Model -> List (Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg)
viewColumns model =
    [ PlotterControl.Navigation.View.view model
    , case model.page of
        Just b ->
            case b of
                PlotterControl.Page.Checklist_ c ->
                    PlotterControl.Checklist.View.view c model

                PlotterControl.Page.File_ c ->
                    PlotterControl.File.View.view c model

                PlotterControl.Page.Tool_ c ->
                    PlotterControl.Tool.View.view c model

        Nothing ->
            { size = \x -> { x | width = clamp 240 448 (x.width // 3) }
            , header = Nothing
            , toolbar = Nothing
            , body = Element.PravdomilUi.Application.Blocks []
            }
    , PlotterControl.Queue.View.view model
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

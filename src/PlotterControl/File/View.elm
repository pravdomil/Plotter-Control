module PlotterControl.File.View exposing (..)

import Element.PravdomilUi exposing (..)
import PlotterControl.Directory.Utils
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Settings.View
import PlotterControl.Utils.Theme exposing (..)
import PlotterControl.Utils.Utils
import PlotterControl.Utils.View


view : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
view model =
    column [ width fill, spacing 16, padding 16 ]
        (case PlotterControl.Directory.Utils.activeFile model of
            Just ( name, a ) ->
                [ heading1 theme
                    []
                    [ textEllipsis [] (name |> PlotterControl.File.nameToString)
                    ]
                , case a.ready of
                    Ok ready ->
                        column [ width fill, spacing 16 ]
                            [ button theme
                                []
                                { label = text "Add to Queue"
                                , onPress = Just (PlotterControl.Msg.AddFileToQueueRequested name)
                                }
                            , markers name ready
                            , PlotterControl.Settings.View.view model name ready.settings
                            ]

                    Err b ->
                        statusParagraph theme
                            []
                            [ case b of
                                PlotterControl.File.FileNotSupported ->
                                    text ("Only " ++ PlotterControl.File.supportedExtension ++ " files are supported.")

                                PlotterControl.File.InvalidMarkerCount ->
                                    text "Failed to load markers."

                                PlotterControl.File.ParserError _ ->
                                    text "Failed to parse file."
                            ]
                ]

            Nothing ->
                [ heading1 theme
                    []
                    [ text "File"
                    ]
                , statusParagraph theme
                    []
                    [ text "No file selected."
                    ]
                ]
        )


markers : PlotterControl.File.Name -> PlotterControl.File.Ready -> Element PlotterControl.Msg.Msg
markers name a =
    PlotterControl.Utils.View.twoRows
        (text "Markers:")
        (case a.markers of
            Just b ->
                row [ spacing 8 ]
                    [ text
                        ([ b.count |> String.fromInt
                         , b.yDistance |> PlotterControl.Utils.Utils.mmToString
                         , b.xDistance |> PlotterControl.Utils.Utils.mmToString
                         ]
                            |> String.join " × "
                        )
                    , textButton theme
                        []
                        { label = text "Test"
                        , onPress = Just (PlotterControl.Msg.MarkerTestRequested name)
                        }
                    ]

            Nothing ->
                text "None"
        )

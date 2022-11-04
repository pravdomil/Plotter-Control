module PlotterControl.File.View exposing (..)

import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import Element.PravdomilUi.Application.Block
import PlotterControl.Directory.Utils
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Settings.View
import PlotterControl.Utils.Theme exposing (..)
import PlotterControl.Utils.Utils
import PlotterControl.Utils.View


view : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view model =
    case PlotterControl.Directory.Utils.activeFile model of
        Just ( name, a ) ->
            { size = \x -> { x | width = max 320 (x.width // 4) }
            , header =
                Just
                    { attributes = []
                    , left = []
                    , center = textEllipsis [ fontVariant fontTabularNumbers ] (PlotterControl.File.nameToString name)
                    , right =
                        [ button theme
                            []
                            { label = text "Add to Queue"
                            , onPress = Just (PlotterControl.Msg.AddFileToQueueRequested name)
                            }
                        ]
                    }
            , toolbar = Nothing
            , body =
                Element.PravdomilUi.Application.Blocks
                    (case a.ready of
                        Ok ready ->
                            [ fileInfo name ready
                            , PlotterControl.Settings.View.view model name ready.settings
                            ]

                        Err b ->
                            Element.PravdomilUi.Application.Block.Status
                                [ case b of
                                    PlotterControl.File.FileNotSupported ->
                                        text ("Only " ++ PlotterControl.File.supportedExtension ++ " files are supported.")

                                    PlotterControl.File.InvalidMarkerCount ->
                                        text "Failed to load markers."

                                    PlotterControl.File.ParserError _ ->
                                        text "Failed to parse file."
                                ]
                    )
            }

        Nothing ->
            { size = \x -> { x | width = max 320 (x.width // 4) }
            , header =
                Just
                    { attributes = []
                    , left = []
                    , center = textEllipsis [] "File"
                    , right = []
                    }
            , toolbar = Nothing
            , body =
                Element.PravdomilUi.Application.Blocks
                    [ Element.PravdomilUi.Application.Block.Status
                        [ text "No file selected."
                        ]
                    ]
            }


fileInfo : PlotterControl.File.Name -> PlotterControl.File.Ready -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
fileInfo name a =
    Element.PravdomilUi.Application.Block.Block
        (Just "Info")
        [ PlotterControl.Utils.View.twoRows
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
                    [ text "None"
                    ]
            )
        ]

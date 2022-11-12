module PlotterControl.File.View exposing (..)

import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import Element.PravdomilUi.Application.Block
import PlotterControl.Directory.Utils
import PlotterControl.File
import PlotterControl.Markers
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Page
import PlotterControl.Settings.View
import PlotterControl.Utils.Theme exposing (..)
import PlotterControl.Utils.Utils
import PlotterControl.Utils.View


view : PlotterControl.Page.File -> PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view { name } model =
    let
        size : Element.PravdomilUi.Application.ViewportSize -> Element.PravdomilUi.Application.ViewportSize
        size x =
            { x | width = clamp 240 448 (x.width // 3) }
    in
    case PlotterControl.Directory.Utils.fileByName name model of
        Just a ->
            { size = size
            , header =
                Just
                    { attributes = []
                    , left = []
                    , center = textEllipsis [ fontCenter, fontVariant fontTabularNumbers ] ("File " ++ PlotterControl.File.nameToString name)
                    , right =
                        [ textButton theme
                            [ fontSemiBold ]
                            { label = text "Enqueue"
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
                            [ Element.PravdomilUi.Application.Block.Status
                                [ case b of
                                    PlotterControl.File.FileNotSupported ->
                                        text ("Only " ++ PlotterControl.File.supportedExtension ++ " files are supported.")

                                    PlotterControl.File.ParserError _ ->
                                        text "Failed to parse file."

                                    PlotterControl.File.MarkersError c ->
                                        case c of
                                            PlotterControl.Markers.InvalidMarkerCount ->
                                                text "Failed to load markers."
                                ]
                            ]
                    )
            }

        Nothing ->
            { size = size
            , header =
                Just
                    { attributes = []
                    , left = []
                    , center = textEllipsis [ fontCenter ] "File"
                    , right = []
                    }
            , toolbar = Nothing
            , body =
                Element.PravdomilUi.Application.Blocks
                    [ Element.PravdomilUi.Application.Block.Status
                        [ text "File not found."
                        ]
                    ]
            }


fileInfo : PlotterControl.File.Name -> PlotterControl.File.Ready -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
fileInfo name a =
    Element.PravdomilUi.Application.Block.Block
        (Just "Info")
        [ PlotterControl.Utils.View.twoColumns
            "Markers:"
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
                            , onPress = Just (PlotterControl.Msg.FileMarkerTestRequested name)
                            }
                        ]

                Nothing ->
                    text "None"
            )
        ]

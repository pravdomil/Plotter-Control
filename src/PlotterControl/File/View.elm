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
                    , left =
                        [ textButton theme
                            []
                            { label = text "Download"
                            , onPress = Just (PlotterControl.Msg.DownloadSvgRequested name)
                            }
                        ]
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
                            [ PlotterControl.Settings.View.view model name ready.settings
                            , case ready.markers of
                                Just b ->
                                    markers name b

                                Nothing ->
                                    Element.PravdomilUi.Application.Block.Empty
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


markers : PlotterControl.File.Name -> PlotterControl.Markers.Markers -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
markers name a =
    Element.PravdomilUi.Application.Block.Block
        (Just "Markers")
        [ PlotterControl.Utils.View.twoColumns
            "Size:"
            (row [ spacing 8 ]
                [ text
                    ([ a.count |> String.fromInt
                     , a.yDistance |> PlotterControl.Utils.Utils.lengthToString
                     , a.xDistance |> PlotterControl.Utils.Utils.lengthToString
                     ]
                        |> String.join " × "
                    )
                , textButton theme
                    []
                    { label = text "Test"
                    , onPress = Just (PlotterControl.Msg.FileMarkerTestRequested name)
                    }
                ]
            )
        , PlotterControl.Utils.View.twoColumns
            "Loading:"
            (inputRadioRow theme
                []
                { label = labelHidden "Loading:"
                , options =
                    [ inputRadioBlockOption theme [] PlotterControl.Markers.LoadContinually (text "Continually")
                    , inputRadioBlockOption theme [] PlotterControl.Markers.LoadSimultaneously (text "Simultaneously")
                    ]
                , selected = Just a.loading
                , onChange = PlotterControl.Msg.MarkerLoadingChanged name
                }
            )
        ]

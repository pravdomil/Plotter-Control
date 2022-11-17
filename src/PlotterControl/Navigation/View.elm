module PlotterControl.Navigation.View exposing (..)

import Dict.Any
import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import Element.PravdomilUi.Application.Block
import PlotterControl.Checklist
import PlotterControl.Checklist.Utils
import PlotterControl.Directory
import PlotterControl.Directory.Utils
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Tool
import PlotterControl.Tool.Utils
import PlotterControl.Utils.Theme exposing (..)
import Time


view : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view model =
    { size = \x -> { x | width = clamp 240 448 (x.width // 3) }
    , header =
        Just
            { attributes = []
            , left =
                [ textButton theme
                    []
                    { label = text "Reset"
                    , onPress = Just PlotterControl.Msg.Reset
                    }
                ]
            , center = text "Plotter Control"
            , right =
                [ textButton theme
                    [ fontSemiBold ]
                    { label = text "Open"
                    , onPress = Just PlotterControl.Msg.OpenFilesRequested
                    }
                ]
            }
    , toolbar = Nothing
    , body =
        Element.PravdomilUi.Application.Blocks
            [ viewChecklists model
            , Element.PravdomilUi.Application.Block.Block
                (Just "Files")
                (case model.directory of
                    Ok b ->
                        [ viewFiles model b
                        ]

                    Err () ->
                        [ statusText theme
                            [ paddingXY 8 0 ]
                            "Open file first."
                        ]
                )
            , viewTools model
            ]
    }


viewFiles : PlotterControl.Model.Model -> PlotterControl.Directory.Directory -> Element PlotterControl.Msg.Msg
viewFiles model a =
    inputRadio theme
        [ width fill ]
        { label = labelHidden "Files"
        , options =
            a.files
                |> Dict.Any.toList
                |> List.sortBy (\( _, x ) -> x.created |> Time.posixToMillis |> negate)
                |> List.map
                    (\( x, _ ) ->
                        inputRadioBlockOption theme [ width fill ] x (textEllipsis [] (PlotterControl.File.nameToString x))
                    )
        , selected = PlotterControl.Directory.Utils.activeFilename model
        , onChange = PlotterControl.Msg.FileActivated
        }



--


viewChecklists : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
viewChecklists model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Checklists")
        [ inputRadio theme
            [ width fill ]
            { label = labelHidden "Checklists"
            , options = PlotterControl.Checklist.all |> List.map (viewChecklist model)
            , selected = PlotterControl.Checklist.Utils.activeChecklist model
            , onChange = PlotterControl.Msg.ChecklistActivated
            }
        ]


viewChecklist : PlotterControl.Model.Model -> PlotterControl.Checklist.Checklist -> InputOption PlotterControl.Checklist.Checklist PlotterControl.Msg.Msg
viewChecklist model a =
    let
        items : List PlotterControl.Checklist.Item
        items =
            PlotterControl.Checklist.items a

        done : Int
        done =
            items
                |> List.filterMap
                    (\x ->
                        Dict.Any.get PlotterControl.Checklist.itemToComparable x model.checklist
                    )
                |> List.length

        total : Int
        total =
            List.length items

        text : String
        text =
            PlotterControl.Checklist.toName a ++ " " ++ String.fromInt (round ((toFloat done / toFloat total) * 100)) ++ "%"
    in
    inputRadioBlockOption theme [ width fill ] a (textEllipsis [ fontVariant fontTabularNumbers ] text)



--


viewTools : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Block.Block PlotterControl.Msg.Msg
viewTools model =
    Element.PravdomilUi.Application.Block.Block
        (Just "Tools")
        [ inputRadio theme
            [ width fill ]
            { label = labelHidden "Tools"
            , options =
                PlotterControl.Tool.all
                    |> List.map
                        (\x ->
                            inputRadioBlockOption theme [ width fill ] x (textEllipsis [] (PlotterControl.Tool.toName x))
                        )
            , selected = PlotterControl.Tool.Utils.activeTool model
            , onChange = PlotterControl.Msg.ToolActivated
            }
        ]

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
import PlotterControl.Utils.Theme exposing (..)
import Time


view : PlotterControl.Model.Model -> Element.PravdomilUi.Application.Column PlotterControl.Msg.Msg
view model =
    { size = \x -> { x | width = max 240 (x.width // 3) }
    , header =
        Just
            { attributes = []
            , left = []
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
                        [ paragraph theme
                            [ paddingXY 8 8, fontSize 15, fontColor style.fore60 ]
                            [ text "Open file first."
                            ]
                        ]
                )
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
            String.fromInt done ++ "/" ++ String.fromInt total ++ " " ++ checklistName a
    in
    inputRadioBlockOption theme [ width fill ] a (textEllipsis [ fontVariant fontTabularNumbers ] text)


checklistName : PlotterControl.Checklist.Checklist -> String
checklistName a =
    case a of
        PlotterControl.Checklist.MediaChecklist ->
            "Media"

        PlotterControl.Checklist.MarkersChecklist ->
            "Markers"

        PlotterControl.Checklist.DrawingChecklist ->
            "Drawing"

        PlotterControl.Checklist.CuttingChecklist ->
            "Cutting"

        PlotterControl.Checklist.PerforationChecklist ->
            "Perforation"

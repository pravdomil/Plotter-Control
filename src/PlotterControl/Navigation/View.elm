module PlotterControl.Navigation.View exposing (..)

import Dict.Any
import Element.PravdomilUi exposing (..)
import Element.PravdomilUi.Application
import Element.PravdomilUi.Application.Block
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
            [ case model.directory of
                Ok b ->
                    Element.PravdomilUi.Application.Block.Block
                        (Just "Files")
                        [ viewFiles model b
                        ]

                Err () ->
                    Element.PravdomilUi.Application.Block.Status
                        [ text "Open file first."
                        ]
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

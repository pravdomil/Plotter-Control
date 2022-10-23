module PlotterControl.Directory.View exposing (..)

import Dict.Any
import Element.PravdomilUi exposing (..)
import PlotterControl.Directory
import PlotterControl.File
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Utils.Theme exposing (..)
import Time


view : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
view model =
    column [ width fill, spacing 16, padding 16 ]
        [ heading1 theme
            []
            [ text "Plotter Control"
            ]
        , button theme
            []
            { label = text "Open Files"
            , onPress = Just PlotterControl.Msg.OpenFilesRequested
            }
        , case model.directory of
            Ok a ->
                viewFiles model a

            Err () ->
                none
        ]


viewFiles : PlotterControl.Model.Model -> PlotterControl.Directory.Directory -> Element PlotterControl.Msg.Msg
viewFiles _ a =
    inputRadio theme
        [ width fill ]
        { label = labelAbove theme [ paddingEach 0 0 0 8 ] (text "Files")
        , options =
            a.files
                |> Dict.Any.toList
                |> List.sortBy (\( _, x ) -> x.created |> Time.posixToMillis |> negate)
                |> List.map
                    (\( x, _ ) ->
                        inputRadioBlockOption theme [ width fill ] x (textEllipsis [] (PlotterControl.File.nameToString x))
                    )
        , selected = a.active
        , onChange = PlotterControl.Msg.FileActivated
        }

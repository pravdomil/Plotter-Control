module PlotterControl.Queue.View exposing (..)

import Dict.Any
import Element.PravdomilUi exposing (..)
import FeatherIcons
import PlotterControl.Model
import PlotterControl.Msg
import PlotterControl.Queue
import PlotterControl.Utils.Theme exposing (..)
import PlotterControl.Utils.View
import Time


view : PlotterControl.Model.Model -> Element PlotterControl.Msg.Msg
view model =
    column [ width fill, spacing 16, padding 16 ]
        [ heading1 theme
            []
            [ text "Queue"
            ]
        , case model.queue |> Dict.Any.isEmpty of
            True ->
                statusParagraph theme
                    []
                    [ text "Is empty."
                    ]

            False ->
                column [ width fill, spacing 16 ]
                    [ plotterStatus model
                    , inputRadio theme
                        [ width fill ]
                        { label = labelAbove theme [ paddingEach 0 0 0 8 ] (text "Items")
                        , options =
                            model.queue
                                |> Dict.Any.toList
                                |> List.sortBy (\( _, x ) -> x.created |> Time.posixToMillis)
                                |> List.map
                                    (\( id, x ) ->
                                        inputRadioBlockOption
                                            theme
                                            [ width fill ]
                                            id
                                            (row [ width fill ]
                                                [ textEllipsis [] (PlotterControl.Queue.itemNameToString x.name)
                                                , textButton theme
                                                    []
                                                    { label = FeatherIcons.x |> PlotterControl.Utils.View.iconToElement
                                                    , onPress = Just (PlotterControl.Msg.QueueItemRemoveRequested id)
                                                    }
                                                ]
                                            )
                                    )
                        , selected = Nothing
                        , onChange = always PlotterControl.Msg.NothingHappened
                        }
                    ]
        ]

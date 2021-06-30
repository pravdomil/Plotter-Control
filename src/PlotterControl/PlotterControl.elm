module PlotterControl.PlotterControl exposing (..)

import File exposing (File)
import PlotterControl.Data.HpGl as HpGl exposing (HpGl)
import PlotterControl.Filename as Filename exposing (Filename)
import PlotterControl.Interop exposing (Status(..))
import PlotterControl.Translation exposing (..)
import PlotterControl.Ui.Base exposing (..)
import Task


type alias Model =
    { status : Status
    , file :
        Maybe
            { filename : Result String Filename
            , content : HpGl
            }
    }


init : Model
init =
    { status = Ready
    , file = Nothing
    }



--


type Msg
    = GotStatus Status
    | GotFile File
    | GotFileContent File String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotStatus b ->
            ( { model | status = b }
            , Cmd.none
            )

        GotFile b ->
            ( model
            , File.toString b |> Task.perform (GotFileContent b)
            )

        GotFileContent b c ->
            ( { model
                | file =
                    Just
                        { filename = Filename.fromString (File.name b)
                        , content = HpGl.fromString c
                        }
              }
            , Cmd.none
            )



--


subscriptions : Model -> Sub Msg
subscriptions _ =
    PlotterControl.Interop.statusSubscription GotStatus



--


view : Model -> Element Msg
view model =
    column []
        [ h6 []
            [ text (t A_Title)
            ]
        , viewStatus model
        , viewFile model
        ]


viewStatus : Model -> Element Msg
viewStatus model =
    let
        color : Color
        color =
            case model.status of
                Ready ->
                    primary

                Connecting ->
                    primary

                Busy ->
                    danger

                Error _ ->
                    danger
    in
    column []
        [ h6 [ fontColor grey4 ]
            [ text (t (A_Raw "Status"))
            ]
        , h3 [ fontColor color ]
            [ text (t (PlotterControl.Translation.status model.status))
            ]
        ]


viewFile : Model -> Element Msg
viewFile model =
    column
        []
        [ h6 [ fontColor grey4 ]
            [ text (t (A_Raw "File"))
            ]
        , case model.file of
            Just b ->
                case b.filename of
                    Ok c ->
                        viewFilename c

                    Err c ->
                        column []
                            [ h3 [ fontColor primary ]
                                [ text (c |> String.replace "_" "_\u{200B}")
                                ]
                            , p [ fontColor danger, fontSemiBold ]
                                [ text (t (A_Raw "Can't parse filename."))
                                ]
                            ]

            Nothing ->
                h3 []
                    [ text (t (A_Raw "No file loaded."))
                    ]
        , p [ fontColor grey4 ]
            [ text (t (A_Raw "Filename:"))
            , text " "
            , text Filename.format
            ]
        ]


viewFilename : Filename -> Element msg
viewFilename a =
    column []
        [ h3 [ fontColor primary ]
            [ text a.name
            ]
        , row []
            [ text (t (A_Raw "Width:"))
            , text (String.fromFloat a.markerDistanceX)
            , text "mm"
            ]
        , row []
            [ text (t (A_Raw "Length:"))
            , text (String.fromFloat a.markerDistanceY)
            , text "mm"
            , text " x "
            ]
        , row []
            [ text (t (A_Raw "Speed:"))
            , text (String.fromInt a.speed)
            , text "mm/s"
            ]
        , row []
            [ text (t (A_Raw "Copies:"))
            , text (String.fromInt a.copies)
            , text "x"
            ]
        ]

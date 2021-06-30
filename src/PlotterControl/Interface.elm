module PlotterControl.Interface exposing (..)

import File exposing (File)
import Html.Events as Events
import Json.Decode as Decode
import Parser exposing (Parser)
import PlotterControl.Data.HpGl as HpGl exposing (HpGl)
import PlotterControl.Filename as Filename exposing (Filename)
import PlotterControl.Interop.Port as Port
import PlotterControl.Interop.Status as Status exposing (Status)
import PlotterControl.Translation as Translation
import PlotterControl.Ui.Base exposing (..)
import Task


type alias Model =
    { status : Status
    , file :
        Maybe
            { name : String
            , filename : Result (List Parser.DeadEnd) Filename
            , content : HpGl
            }
    }


init : Model
init =
    { status = Status.Ready
    , file = Nothing
    }



--


type Msg
    = GotStatus Status
    | GotFile File
    | GotFileContent File String
    | DragOver


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
                        { name = File.name b
                        , filename = Filename.fromString (File.name b)
                        , content = HpGl.fromString c
                        }
              }
            , Cmd.none
            )

        DragOver ->
            ( model
            , Cmd.none
            )



--


subscriptions : Model -> Sub Msg
subscriptions _ =
    Port.statusSubscription GotStatus



--


view : Model -> Element Msg
view model =
    let
        dropDecoder : Decode.Decoder Msg
        dropDecoder =
            Decode.map GotFile
                (Decode.at [ "dataTransfer", "files" ] File.decoder)
    in
    column
        [ height fill
        , padding 32
        , onWithPrevent "dragover" (Decode.succeed DragOver)
        , onWithPrevent "drop" dropDecoder
        ]
        [ viewHeader model
        , viewFile model
        ]


viewHeader : Model -> Element Msg
viewHeader model =
    let
        color : Color
        color =
            case model.status of
                Status.Ready ->
                    primary

                Status.Connecting ->
                    danger

                Status.Busy ->
                    danger

                Status.Error _ ->
                    danger
    in
    column []
        [ h1 []
            [ text Translation.title
            ]
        , el [ paddingEach 0 0 0 16 ] none
        , h2 [ fontColor color ]
            [ text (Translation.status model.status)
            ]
        , el [ paddingEach 0 0 0 64 ] none
        ]


viewFile : Model -> Element Msg
viewFile model =
    column
        [ height fill ]
        [ case model.file of
            Just b ->
                case b.filename of
                    Ok c ->
                        viewFilename c

                    Err c ->
                        column []
                            [ h3 [ fontColor primary ]
                                [ text (b.name |> String.replace "_" "_\u{200B}")
                                ]
                            , p [ fontColor danger, fontSemiBold ]
                                [ text (Translation.raw "Can't parse filename.")
                                ]
                            ]

            Nothing ->
                h3 []
                    [ text (Translation.raw "Drag and drop file to plot.")
                    ]
        , el [ paddingEach 0 0 0 16 ] none
        , el [ height fill ] none
        , p [ fontColor grey4 ]
            [ text (Translation.raw "Filename format:")
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
            [ text (Translation.raw "Width:")
            , text (String.fromFloat a.markerDistanceX)
            , text "mm"
            ]
        , row []
            [ text (Translation.raw "Length:")
            , text (String.fromFloat a.markerDistanceY)
            , text "mm"
            , text " x "
            ]
        , row []
            [ text (Translation.raw "Speed:")
            , text (String.fromInt a.speed)
            , text "mm/s"
            ]
        , row []
            [ text (Translation.raw "Copies:")
            , text (String.fromInt a.copies)
            , text "x"
            ]
        ]



--


onWithPrevent : String -> Decode.Decoder msg -> Attribute msg
onWithPrevent event decoder =
    htmlAttribute
        (Events.preventDefaultOn event
            (Decode.map (\v -> ( v, True )) decoder)
        )

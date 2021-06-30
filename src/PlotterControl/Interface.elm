module PlotterControl.Interface exposing (..)

import File exposing (File)
import Html
import Html.Attributes as Attributes
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
import Utils.DeadEnds as DeadEnds


type alias Model =
    { status : Status
    , file :
        Maybe
            { name : String
            , filename : Result (List Parser.DeadEnd) Filename
            , data : HpGl
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
            let
                data : HpGl
                data =
                    HpGl.fromString c
            in
            ( { model
                | file =
                    Just
                        { name = File.name b
                        , filename = Filename.fromString (File.name b)
                        , data = data
                        }
              }
            , Port.sendData (HpGl.toPlotData data)
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
                (Decode.at [ "dataTransfer", "files", "0" ] File.decoder)
    in
    column
        [ width fill
        , height fill
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
                        column [ spacing 8 ]
                            [ h3 [ fontColor primary ]
                                [ text (b.name |> String.replace "_" "_\u{200B}")
                                ]
                            , p [ fontColor danger, fontSemiBold ]
                                [ text (Translation.raw "Can't parse filename.") ]
                            , p [ fontColor grey4, htmlAttribute (Attributes.style "white-space" "pre") ]
                                [ html (Html.text (DeadEnds.toString c))
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
    let
        onOff : Bool -> String
        onOff b =
            if b then
                "on"

            else
                "off"
    in
    column [ spacing 8, fontColor grey4 ]
        [ h3 [ fontColor primary ]
            [ text a.name
            ]
        , p []
            [ text (Translation.raw "Horizontal marker distance: " ++ String.fromFloat a.markerDistanceX ++ "mm")
            ]
        , p []
            [ text (Translation.raw "Vertical marker distance: " ++ String.fromFloat a.markerDistanceY ++ "mm")
            ]
        , p []
            [ text (Translation.raw "Number of markers: " ++ String.fromInt a.markerCount)
            ]
        , p []
            [ text (Translation.raw "Speed: " ++ String.fromInt a.speed ++ "mm/s")
            ]
        , p []
            [ text (Translation.raw "Copies: " ++ String.fromInt a.copies ++ "x")
            ]
        , p []
            [ text (Translation.raw "Perforation: " ++ onOff a.perforation)
            ]
        ]



--


onWithPrevent : String -> Decode.Decoder msg -> Attribute msg
onWithPrevent event decoder =
    htmlAttribute
        (Events.preventDefaultOn event
            (Decode.map (\v -> ( v, True )) decoder)
        )

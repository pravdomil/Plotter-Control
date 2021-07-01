module PlotterControl.Interface exposing (..)

import File exposing (File)
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Parser exposing (Parser)
import PlotterControl.Data.PlotData exposing (PlotData)
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
        Result
            Error
            { filename : Filename
            , data : Result (List Parser.DeadEnd) PlotData
            }
    }


type Error
    = NoFile
    | FilenameParserError (List Parser.DeadEnd)


init : Model
init =
    { status = Status.Ready
    , file = Err NoFile
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

        GotFileContent b _ ->
            let
                file =
                    File.name b
                        |> Filename.fromString
                        |> Result.map (\v -> { filename = v, data = Err [] })
                        |> Result.mapError FilenameParserError
            in
            ( { model | file = file }
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
        [ h3 []
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
            Ok b ->
                viewFilename b.filename

            Err b ->
                case b of
                    NoFile ->
                        h3 []
                            [ text (Translation.raw "Drag and drop file to plot.")
                            ]

                    FilenameParserError c ->
                        column [ spacing 8 ]
                            [ p [ fontColor danger, fontSemiBold ]
                                [ text (Translation.raw "Can't parse filename.") ]
                            , p [ fontColor grey4, htmlAttribute (Attributes.style "white-space" "pre") ]
                                [ html (Html.text (DeadEnds.toString c))
                                ]
                            ]
        , el [ paddingEach 0 0 0 16 ] none
        , el [ height fill ] none
        , p [ fontSize 14, fontColor grey4 ]
            [ text (Translation.raw "Filename format:")
            , text " "
            , text Filename.format
            ]
        ]


viewFilename : Filename -> Element msg
viewFilename a =
    column [ spacing 8, fontColor grey4 ]
        [ h1 [ fontColor primary ]
            [ text a.name
            ]
        , p []
            [ text
                (Translation.raw "Horizontal marker distance: "
                    ++ (a.markers
                            |> Maybe.map (\v -> String.fromFloat v.x ++ "mm")
                            |> Maybe.withDefault Translation.na
                       )
                )
            ]
        , p []
            [ text
                (Translation.raw "Vertical marker distance: "
                    ++ (a.markers
                            |> Maybe.map (\v -> String.fromFloat v.y ++ "mm")
                            |> Maybe.withDefault Translation.na
                       )
                )
            ]
        , p []
            [ text
                (Translation.raw "Number of markers: "
                    ++ (a.markers
                            |> Maybe.map (\v -> String.fromInt v.count)
                            |> Maybe.withDefault Translation.na
                       )
                )
            ]
        , p []
            [ text
                (Translation.raw "Speed: "
                    ++ (a.speed
                            |> Maybe.map (\v -> String.fromInt v ++ "mm/s")
                            |> Maybe.withDefault Translation.na
                       )
                )
            ]
        , p []
            [ text
                (Translation.raw "Copies: "
                    ++ (a.copies
                            |> Maybe.map (\v -> String.fromInt v ++ "x")
                            |> Maybe.withDefault Translation.na
                       )
                )
            ]
        , p []
            [ text
                (Translation.raw "Tool: "
                    ++ (a.tool
                            |> Maybe.map Translation.tool
                            |> Maybe.withDefault Translation.na
                       )
                )
            ]
        , p []
            [ text
                (Translation.raw "Cut: "
                    ++ (a.cut
                            |> Maybe.map Translation.cut
                            |> Maybe.withDefault Translation.na
                       )
                )
            ]
        , p []
            [ text
                (Translation.raw "Format: "
                    ++ (a.format
                            |> Translation.format
                       )
                )
            ]
        ]



--


onWithPrevent : String -> Decode.Decoder msg -> Attribute msg
onWithPrevent event decoder =
    htmlAttribute
        (Events.preventDefaultOn event
            (Decode.map (\v -> ( v, True )) decoder)
        )

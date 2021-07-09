module PlotterControl.Interface exposing (..)

import File exposing (File)
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Parser exposing (Parser)
import PlotterControl.Data.Dmpl as Dmpl exposing (Dmpl)
import PlotterControl.Data.HpGl as HpGl exposing (HpGl)
import PlotterControl.Data.PlotData as PlotData exposing (PlotData)
import PlotterControl.Filename as Filename exposing (Filename)
import PlotterControl.Interop.Port as Port
import PlotterControl.Interop.Status as Status exposing (Status)
import PlotterControl.Translation as Translation
import PlotterControl.Ui.Base exposing (..)
import PlotterControl.Ui.Style as Style
import Task
import Utils.DeadEnds as DeadEnds


type alias Model =
    { status : Status
    , file : Result Error File_
    }


type Error
    = NoFile
    | Loading
    | FilenameParserError (List Parser.DeadEnd)


type alias File_ =
    { filename : Filename
    , data : Result (List Parser.DeadEnd) PlotData
    }


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
    | Plot


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotStatus b ->
            ( { model | status = b }
            , Cmd.none
            )

        GotFile b ->
            ( { model | file = Err Loading }
            , File.toString b |> Task.perform (GotFileContent b)
            )

        GotFileContent b c ->
            let
                file : Result Error File_
                file =
                    File.name b
                        |> Filename.fromString
                        |> Result.map (\v -> { filename = v, data = toData v })
                        |> Result.mapError FilenameParserError

                toData : Filename -> Result (List Parser.DeadEnd) PlotData
                toData d =
                    (case d.format of
                        Filename.Dmpl ->
                            Dmpl.fromString c
                                |> Result.map PlotData.fromDmpl

                        Filename.HpGL ->
                            HpGl.fromString c
                                |> Result.map PlotData.fromHpGl
                    )
                        |> Result.map
                            (\v ->
                                let
                                    ( prefix, suffix ) =
                                        Filename.toSumma d
                                in
                                [ prefix |> PlotData.fromSumma
                                , v
                                , suffix |> PlotData.fromSumma
                                ]
                                    |> PlotData.concat
                            )
            in
            ( { model | file = file }
            , Cmd.none
            )

        DragOver ->
            ( model
            , Cmd.none
            )

        Plot ->
            ( model
            , model.file
                |> Result.toMaybe
                |> Maybe.andThen (.data >> Result.toMaybe)
                |> Maybe.map Port.sendData
                |> Maybe.withDefault Cmd.none
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
        color : Attribute msg
        color =
            case model.status of
                Status.Ready ->
                    noneAttribute

                Status.Connecting ->
                    fontColor danger

                Status.Sending ->
                    fontColor danger

                Status.Error _ ->
                    fontColor danger
    in
    column []
        [ h2 [ color ]
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
                        h1 [ fontColor primary ]
                            [ text (Translation.raw "Drag and drop plot file.")
                            ]

                    Loading ->
                        h1 []
                            [ text (Translation.raw "Loading...")
                            ]

                    FilenameParserError c ->
                        column [ spacing 8 ]
                            [ h1 [ fontColor danger ]
                                [ text (Translation.raw "Can't parse filename.") ]
                            , p [ fontColor grey4, htmlAttribute (Attributes.style "white-space" "pre") ]
                                [ html (Html.text (DeadEnds.toString c))
                                ]
                            ]
        , el [ paddingEach 0 0 0 16 ] none
        , el [ height fill ] none
        , p [ fontSize 12, fontColor grey4 ]
            (Filename.format
                |> (::) (Translation.raw "Filename format:")
                |> List.map text
                |> List.intersperse br
            )
        ]


viewFilename : Filename -> Element Msg
viewFilename a =
    column [ spacing 8, fontColor grey4 ]
        [ button [ fontSize Style.h1FontSize ]
            { label = text (Translation.raw "Plot " ++ a.name)
            , onPress = Just Plot
            }
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
                (Translation.raw "Number of vertical markers: "
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
                (Translation.raw "Tool: "
                    ++ (a.tool
                            |> Maybe.map Translation.tool
                            |> Maybe.withDefault Translation.na
                       )
                )
            ]
        , p []
            [ text
                (Translation.raw "FlexCut: "
                    ++ (a.flexCut
                            |> Maybe.map Translation.flexCut
                            |> Maybe.withDefault Translation.na
                       )
                )
            ]
        , p []
            [ text
                (Translation.raw "Copies: "
                    ++ String.fromInt a.copies
                    ++ "x"
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

module PlotterControl exposing (..)

import Data.Filename exposing (Filename)
import Data.HpGl as HpGl exposing (HpGl)
import Data.SummaCommand as SummaCommand
import Dict exposing (Dict)
import File exposing (File)
import File.Select
import Html exposing (..)
import Html.Attributes exposing (autofocus, style, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Interop exposing (Status(..), sendData)
import Styles.C as C
import Task
import Translation exposing (..)
import View.Layout exposing (..)


type alias Model =
    { console : String
    , status : Status
    , file :
        Maybe
            { filename : Result String Filename
            , content : HpGl
            }
    }


init : Model
init =
    { console = ""
    , status = Ready
    , file = Nothing
    }



--


type Msg
    = ConsoleChanged String
    | ConsoleSubmitted
      --
    | LoadFile
    | LoadMarkers
    | SetSensitivity Int
    | PlotFile
      --
    | GotStatus Status
    | GotFile File
    | GotFileContent File String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ConsoleChanged b ->
            ( { model | console = b }
            , Cmd.none
            )

        ConsoleSubmitted ->
            ( { model | console = "" }
            , case model |> commandFromModel |> Maybe.andThen identity of
                Just a ->
                    Task.succeed () |> Task.perform (always a.msg)

                Nothing ->
                    Cmd.none
            )

        --
        LoadFile ->
            ( model
            , File.Select.file [] GotFile
            )

        LoadMarkers ->
            ( model
            , SummaCommand.LoadMarkers
                |> SummaCommand.toHpGl
                |> (case model.file |> Maybe.andThen (.filename >> Result.toMaybe) of
                        Just a ->
                            Filename.toHpGl { a | copies = 1 }

                        Nothing ->
                            identity
                   )
                |> sendData
            )

        SetSensitivity b ->
            ( model
            , sendData (SummaCommand.Set ("OPOS_LEVEL=" ++ String.fromInt b) |> SummaCommand.toHpGl)
            )

        PlotFile ->
            ( model
            , case model.file of
                Just a ->
                    case a.filename of
                        Ok b ->
                            sendData (Filename.toHpGl b a.content)

                        Err _ ->
                            sendData a.content

                Nothing ->
                    Cmd.none
            )

        --
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
    Interop.statusSubscription GotStatus



--


view : Model -> Layout Msg
view model =
    column ratio1
        []
        [ element (rem 4)
            []
            (h6 [ C.m3 ]
                [ text (t A_Title)
                ]
            )
        , row ratio1
            []
            [ column (ratio 1)
                [ C.borderEnd ]
                [ viewConsole model
                , viewCommands model
                ]
            , column (ratio 1.618)
                []
                [ viewStatus model
                , viewFile model
                ]
            ]
        ]


viewConsole : Model -> Layout Msg
viewConsole model =
    let
        command : Maybe (Maybe (Command Msg))
        command =
            model |> commandFromModel

        isValid : Attribute msg
        isValid =
            case command of
                Just a ->
                    case a of
                        Just _ ->
                            C.none

                        Nothing ->
                            C.isInvalid

                Nothing ->
                    C.none
    in
    scroll (rem 6)
        []
        [ form [ C.mx3, onSubmit ConsoleSubmitted ]
            [ h6 [ C.textMuted ]
                [ text (t (A_Raw "Console"))
                ]
            , input
                [ C.formControl
                , isValid
                , autofocus True
                , value model.console
                , onInput ConsoleChanged
                ]
                []
            , div [ C.mt1, style "font-size" "14px", C.fwBolder ]
                [ case command of
                    Just a ->
                        case a of
                            Just b ->
                                span [ C.textPrimary ]
                                    [ text b.description
                                    ]

                            Nothing ->
                                span [ C.textDanger ]
                                    [ text (t (A_Raw "Unknown command."))
                                    ]

                    Nothing ->
                        text "\u{00A0}"
                ]
            ]
        ]


viewCommands : Model -> Layout Msg
viewCommands _ =
    scroll ratio1
        []
        [ div [ C.mx3, style "font-size" "14px" ]
            [ h6 [ C.textMuted ]
                [ text (t (A_Raw "Commands"))
                ]
            , table [ C.mb1 ]
                [ tbody []
                    (commands
                        |> Dict.values
                        |> List.take 10
                        |> List.map viewCommand
                    )
                ]
            , p []
                [ small []
                    [ text (t (A_Raw "Note: Lower OPOS sensitivity means more sensitivity."))
                    ]
                ]
            ]
        ]


viewCommand : Command Msg -> Html Msg
viewCommand a =
    tr [ style "cursor" "pointer", onClick a.msg ]
        [ td [ C.fwBolder, C.p0, C.pe1 ]
            [ text (String.toUpper a.name)
            ]
        , td []
            [ text a.description
            ]
        ]


viewStatus : Model -> Layout Msg
viewStatus model =
    let
        textColor : Attribute msg
        textColor =
            case model.status of
                Ready ->
                    C.textPrimary

                Connecting ->
                    C.textPrimary

                Busy ->
                    C.textDanger

                Error _ ->
                    C.textDanger
    in
    scroll (rem 6)
        []
        [ h6 [ C.mx3, C.textMuted ]
            [ text (t (A_Raw "Status"))
            ]
        , h3 [ C.mx3, textColor ]
            [ text (t (Translation.status model.status))
            ]
        ]


viewFile : Model -> Layout Msg
viewFile model =
    scroll ratio1
        []
        [ h6 [ C.mx3, C.textMuted ]
            [ text (t (A_Raw "File"))
            ]
        , case model.file of
            Just b ->
                case b.filename of
                    Ok c ->
                        viewFilename c

                    Err c ->
                        div [ C.mx3 ]
                            [ h3 [ C.textPrimary ]
                                [ text (c |> String.replace "_" "_\u{200B}")
                                ]
                            , p [ C.mb1, C.textDanger, C.fwBolder, style "font-size" "14px" ]
                                [ text (t (A_Raw "Can't parse filename."))
                                ]
                            ]

            Nothing ->
                h3 [ C.mx3 ]
                    [ text (t (A_Raw "No file loaded."))
                    ]
        , p [ C.mx3, C.textMuted, style "font-size" "14px" ]
            [ text (t (A_Raw "Filename:"))
            , text " "
            , text Filename.format
            ]
        ]


viewFilename : Filename -> Html msg
viewFilename a =
    div [ C.mx3 ]
        [ h3 [ C.textPrimary ]
            [ text a.name
            ]
        , table [ style "font-size" "14px", C.mb2 ]
            [ tbody []
                [ tr []
                    [ td [ C.p0, C.pe1 ]
                        [ text (t (A_Raw "Width:"))
                        ]
                    , td []
                        [ text (String.fromFloat a.width)
                        , text "mm"
                        ]
                    ]
                , tr []
                    [ td [ C.p0, C.pe1 ]
                        [ text (t (A_Raw "Length:"))
                        ]
                    , td []
                        [ text (String.fromFloat a.length)
                        , text "mm"
                        , text " x "
                        , text (String.fromInt a.markers)
                        ]
                    ]
                , tr []
                    [ td [ C.p0, C.pe1 ]
                        [ text (t (A_Raw "Speed:"))
                        ]
                    , td []
                        [ text (String.fromInt a.speed)
                        , text "mm/s"
                        ]
                    ]
                , tr []
                    [ td [ C.p0, C.pe1 ]
                        [ text (t (A_Raw "Copies:"))
                        ]
                    , td []
                        [ text (String.fromInt a.copies)
                        , text "x"
                        ]
                    ]
                ]
            ]
        ]



--


type alias Command msg =
    { name : String
    , description : String
    , msg : msg
    }


commands : Dict String (Command Msg)
commands =
    let
        sensitivity : List (Command Msg)
        sensitivity =
            List.range 1 60
                |> List.map
                    (\v ->
                        Command
                            ("s" ++ String.fromInt v)
                            (t (A_Raw ("OPOS sensitivity " ++ String.fromInt v ++ ".")))
                            (SetSensitivity v)
                    )
    in
    [ Command "l" (t (A_Raw "Load file.")) LoadFile
    , Command "m" (t (A_Raw "Markers load.")) LoadMarkers
    , Command "s" (t (A_Raw "OPOS sensitivity 30 (default).")) (SetSensitivity 30)
    , Command "p" (t (A_Raw "Plot file.")) PlotFile
    ]
        ++ sensitivity
        |> List.map (\v -> ( v.name, v ))
        |> Dict.fromList


commandFromString : String -> Maybe (Command Msg)
commandFromString a =
    commands |> Dict.get (a |> String.toLower)


commandFromModel : Model -> Maybe (Maybe (Command Msg))
commandFromModel model =
    case model.console of
        "" ->
            Nothing

        _ ->
            Just (commandFromString model.console)

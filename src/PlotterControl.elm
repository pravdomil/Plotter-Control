module PlotterControl exposing (..)

import Data.Filename as Filename exposing (Filename)
import Data.HpGl as HpGl exposing (HpGl)
import Element exposing (Color)
import Element.Font as Font
import File exposing (File)
import Interop exposing (Status(..))
import Task
import Translation exposing (..)
import Ui exposing (..)


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
    Interop.statusSubscription GotStatus



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
        [ h6 [ Font.color gray600 ]
            [ text (t (A_Raw "Status"))
            ]
        , h3 [ Font.color color ]
            [ text (t (Translation.status model.status))
            ]
        ]


viewFile : Model -> Element Msg
viewFile model =
    column
        []
        [ h6 [ Font.color gray600 ]
            [ text (t (A_Raw "File"))
            ]
        , case model.file of
            Just b ->
                case b.filename of
                    Ok c ->
                        viewFilename c

                    Err c ->
                        column []
                            [ h3 [ Font.color primary ]
                                [ text (c |> String.replace "_" "_\u{200B}")
                                ]
                            , p [ Font.color danger, Font.semiBold ]
                                [ text (t (A_Raw "Can't parse filename."))
                                ]
                            ]

            Nothing ->
                h3 []
                    [ text (t (A_Raw "No file loaded."))
                    ]
        , p [ Font.color gray600 ]
            [ text (t (A_Raw "Filename:"))
            , text " "
            , text Filename.format
            ]
        ]


viewFilename : Filename -> Element msg
viewFilename a =
    column []
        [ h3 [ Font.color primary ]
            [ text a.name
            ]
        , row []
            [ text (t (A_Raw "Width:"))
            , text (String.fromFloat a.width)
            , text "mm"
            ]
        , row []
            [ text (t (A_Raw "Length:"))
            , text (String.fromFloat a.length)
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

module Views.PlotterControl exposing (Config, Model, Msg, init, publicMsg, subscriptions, update, view)

import File exposing (File)
import File.Select as Select
import Html exposing (Attribute, Html, a, button, div, h3, text)
import Html.Attributes exposing (class, disabled)
import Html.Events exposing (onClick)
import Languages.L as L
import Ports exposing (javaScriptMessageSubscription, sendElmMessage)
import String
import Task
import Tuple exposing (second)
import Types.Messages exposing (ElmMessage(..), JavaScriptMessage(..), JsRefSerialPort, PortStatus(..), SerialOptions, SerialPortFilter)
import Utils.Command exposing (Command(..), commandsToString, offsetBy)
import Utils.Rectangle exposing (PositionX(..), PositionY(..), absolute)
import Utils.RegistrationMark exposing (registrationMark, registrationMarkSize, registrationMarks)
import Utils.Utils exposing (Point, boolToNumber)


{-| To define what can happen.
-}
type Msg
    = -- Outside World
      GotJavaScriptMessage (Maybe JavaScriptMessage)
      -- UI
    | ConnectToPlotter
    | ChoosePlotFile
    | GotPlotFile File
    | GotPlotFileAndContent File String
    | SelectRegistrationMark Point
    | SelectPlotFile
    | Plot


{-| To make some messages available outside this module.
-}
publicMsg =
    {}


{-| To define things we keep.
-}
type alias Model =
    { errors : List String
    , port_ : PortStatus
    , plotFile : Maybe ( File, String )
    , selectionFile : Bool
    , selectionMarks : List Point
    }


{-| To define what things we need.
-}
type alias Config msg =
    { sendMsg : Msg -> msg
    }


{-| To init our view.
-}
init : Config msg -> ( Model, Cmd msg )
init _ =
    ( { errors = []
      , port_ = Idle
      , plotFile = Nothing
      , selectionFile = False
      , selectionMarks = []
      }
    , Cmd.none
    )


{-| To update our view.
-}
update : Config msg -> Msg -> Model -> ( Model, Cmd msg )
update config msg model =
    case msg of
        GotJavaScriptMessage a ->
            case a of
                Just b ->
                    case b of
                        GotError c ->
                            ( { model | errors = c :: model.errors }, Cmd.none )

                        SerialPortUpdated c ->
                            ( { model | port_ = c }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        ConnectToPlotter ->
            ( model
            , sendElmMessage
                (ConnectSerialPort
                    (SerialPortFilter 0x0403 0x6001)
                    (SerialOptions 38400)
                )
            )

        ChoosePlotFile ->
            ( model
            , Select.file [] (GotPlotFile >> config.sendMsg)
            )

        GotPlotFile a ->
            ( model
            , a |> File.toString |> Task.perform (GotPlotFileAndContent a >> config.sendMsg)
            )

        GotPlotFileAndContent a b ->
            ( { model | plotFile = Just ( a, b ) }, Cmd.none )

        SelectRegistrationMark a ->
            if model.selectionMarks |> List.member a then
                ( { model | selectionMarks = model.selectionMarks |> List.filter ((/=) a) }, Cmd.none )

            else
                ( { model | selectionMarks = a :: model.selectionMarks }, Cmd.none )

        SelectPlotFile ->
            ( { model | selectionFile = not model.selectionFile }, Cmd.none )

        Plot ->
            case model.port_ of
                Ready a ->
                    let
                        data : String
                        data =
                            model.selectionMarks
                                |> List.reverse
                                |> List.concatMap (\v -> registrationMark |> List.map (offsetBy v))
                                |> (\v -> List.concat [ [ IN, IP0011 ], v ])
                                |> commandsToString
                                |> (\v ->
                                        if model.selectionFile then
                                            v ++ (model.plotFile |> Maybe.map second |> Maybe.withDefault "")

                                        else
                                            v
                                   )
                                |> (\v -> v ++ String.repeat 10000 ";")
                    in
                    ( model
                    , sendElmMessage (SendToSerialPort a data)
                    )

                _ ->
                    ( model, Cmd.none )


{-| To handle subscriptions.
-}
subscriptions : Config msg -> Model -> Sub msg
subscriptions config _ =
    javaScriptMessageSubscription (GotJavaScriptMessage >> config.sendMsg)


{-| To show interface.
-}
view : Config msg -> Model -> Html msg
view config model =
    div []
        [ h3 (absolute ( Left 2 0, Top 1.5 0 ))
            [ text L.pageTitle ]
        , div (absolute ( Left 2 0, Top 5 0 ))
            [ viewControlInterface config model ]
        , div
            (absolute ( Left 1 0, Bottom 1 0 ) ++ [ class "small text-danger" ])
            (model.errors |> List.map (\v -> div [] [ text v ]))
        ]


{-| To show control interface.
-}
viewControlInterface : Config msg -> Model -> Html msg
viewControlInterface config model =
    div []
        [ div (absolute ( Left 0 30, Top 0 0 ))
            [ button [ class "btn btn-primary", onClick (ChoosePlotFile |> config.sendMsg) ]
                [ text L.choosePlotFile
                ]
            , text " "
            , case model.port_ of
                Idle ->
                    button [ class "btn btn-primary", onClick (ConnectToPlotter |> config.sendMsg) ]
                        [ text L.connectToPlotter
                        ]

                Connecting ->
                    button [ class "btn btn-primary", disabled True ]
                        [ text L.connectingToPlotter
                        ]

                Ready _ ->
                    button
                        [ class "btn btn-danger", onClick (Plot |> config.sendMsg) ]
                        [ text
                            (L.plotButton (model.selectionMarks |> List.length |> (+) (boolToNumber model.selectionFile)))
                        ]

                Busy ->
                    button
                        [ class "btn btn-danger", disabled True ]
                        [ text L.sendingData
                        ]
            ]
        , div (absolute ( Left 0 30, Top 3 0 ) ++ [ class "small" ])
            [ text L.plotterNotes
            ]
        , div (absolute ( Left 0 0, Top 5 0 )) [ viewRegistrationMarks config model ]
        , case model.plotFile of
            Just ( a, _ ) ->
                button
                    (absolute ( Left 4 16, Top 22 4 )
                        ++ [ buttonClass model.selectionFile
                           , onClick (SelectPlotFile |> config.sendMsg)
                           ]
                    )
                    [ text (a |> File.name) ]

            Nothing ->
                text ""
        ]


{-| To view registration marks.
-}
viewRegistrationMarks : Config msg -> Model -> Html msg
viewRegistrationMarks config model =
    let
        scale =
            0.04

        markSize =
            registrationMarkSize * scale

        ( maxX, maxY ) =
            registrationMarks
                |> List.foldl (\( x, y ) ( accX, accY ) -> ( max x accX, max y accY )) ( 0, 0 )

        viewRegistrationMark : Point -> Html msg
        viewRegistrationMark (( x, y ) as point) =
            button
                (absolute ( Left ((maxX - x) * scale) markSize, Top ((maxY - y) * scale) markSize )
                    ++ [ model.selectionMarks |> List.member point |> buttonClass
                       , class "p-0 px-3"
                       , onClick (SelectRegistrationMark point |> config.sendMsg)
                       ]
                )
                []
    in
    div [] (registrationMarks |> List.map viewRegistrationMark)


{-| To get class for selected or unselected button.
-}
buttonClass : Bool -> Attribute msg
buttonClass selected =
    if selected then
        class "btn btn-primary"

    else
        class "btn btn-secondary"

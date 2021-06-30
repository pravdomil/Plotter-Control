module PlotterControl.Main exposing (..)

import Browser exposing (Document)
import Json.Decode as Decode
import PlotterControl.Interface as Interface
import PlotterControl.Translation as Translation
import PlotterControl.Ui.Base exposing (..)


main : Program Decode.Value Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



--


type alias Model =
    { interface : Interface.Model
    }


init : Decode.Value -> ( Model, Cmd Msg )
init _ =
    ( { interface = Interface.init
      }
    , Cmd.none
    )



--


type Msg
    = PlotterControlMsg Interface.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlotterControlMsg a ->
            Interface.update a model.interface
                |> Tuple.mapBoth (\v -> { model | interface = v }) (Cmd.map PlotterControlMsg)



--


subscriptions : Model -> Sub Msg
subscriptions model =
    Interface.subscriptions model.interface
        |> Sub.map PlotterControlMsg



--


view : Model -> Document Msg
view model =
    { title = Translation.title
    , body =
        [ layout []
            (lazy Interface.view model.interface
                |> map PlotterControlMsg
            )
        ]
    }

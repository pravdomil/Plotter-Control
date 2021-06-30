module PlotterControl.Main exposing (..)

import Browser exposing (Document)
import Json.Decode as Decode
import PlotterControl.Interface
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
    { plotterControl : PlotterControl.Interface.Model
    }


init : Decode.Value -> ( Model, Cmd Msg )
init _ =
    ( { plotterControl = PlotterControl.Interface.init
      }
    , Cmd.none
    )



--


type Msg
    = PlotterControlMsg PlotterControl.Interface.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlotterControlMsg a ->
            PlotterControl.Interface.update a model.plotterControl
                |> Tuple.mapBoth (\v -> { model | plotterControl = v }) (Cmd.map PlotterControlMsg)



--


subscriptions : Model -> Sub Msg
subscriptions model =
    PlotterControl.Interface.subscriptions model.plotterControl
        |> Sub.map PlotterControlMsg



--


view : Model -> Document Msg
view model =
    { title = Translation.title
    , body =
        [ layout []
            (lazy PlotterControl.Interface.view model.plotterControl
                |> map PlotterControlMsg
            )
        ]
    }

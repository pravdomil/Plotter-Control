module PlotterControl.Main exposing (..)

import Browser exposing (Document)
import Json.Decode as Decode
import PlotterControl.PlotterControl
import PlotterControl.Translation exposing (Translation(..), t)
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
    { plotterControl : PlotterControl.PlotterControl.Model
    }


init : Decode.Value -> ( Model, Cmd Msg )
init _ =
    ( { plotterControl = PlotterControl.PlotterControl.init
      }
    , Cmd.none
    )



--


type Msg
    = PlotterControlMsg PlotterControl.PlotterControl.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlotterControlMsg a ->
            PlotterControl.PlotterControl.update a model.plotterControl
                |> Tuple.mapBoth (\v -> { model | plotterControl = v }) (Cmd.map PlotterControlMsg)



--


subscriptions : Model -> Sub Msg
subscriptions model =
    PlotterControl.PlotterControl.subscriptions model.plotterControl
        |> Sub.map PlotterControlMsg



--


view : Model -> Document Msg
view model =
    { title = t A_Title
    , body =
        [ layout []
            (lazy PlotterControl.PlotterControl.view model.plotterControl
                |> map PlotterControlMsg
            )
        ]
    }

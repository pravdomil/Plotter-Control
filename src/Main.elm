module Main exposing (..)

import Browser exposing (Document)
import Element
import Element.Lazy as Lazy
import Json.Decode as Decode
import PlotterControl
import Translation exposing (Translation(..), t)
import Ui exposing (..)


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
    { plotterControl : PlotterControl.Model
    }


init : Decode.Value -> ( Model, Cmd Msg )
init _ =
    ( { plotterControl = PlotterControl.init
      }
    , Cmd.none
    )



--


type Msg
    = PlotterControlMsg PlotterControl.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlotterControlMsg a ->
            PlotterControl.update a model.plotterControl
                |> Tuple.mapBoth (\v -> { model | plotterControl = v }) (Cmd.map PlotterControlMsg)



--


subscriptions : Model -> Sub Msg
subscriptions model =
    PlotterControl.subscriptions model.plotterControl
        |> Sub.map PlotterControlMsg



--


view : Model -> Document Msg
view model =
    { title = t A_Title
    , body =
        [ Element.layout (Ui.rootStyle [])
            (Lazy.lazy PlotterControl.view model.plotterControl
                |> Element.map PlotterControlMsg
            )
        ]
    }

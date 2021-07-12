module PlotterControl.Data.PlotData exposing (..)

import PlotterControl.Data.Dmpl as Dmpl exposing (Dmpl)
import PlotterControl.Data.HpGl as HpGl exposing (HpGl)
import PlotterControl.Data.Summa as Summa exposing (Summa)


type PlotData
    = PlotData String


fromString : String -> PlotData
fromString =
    PlotData


toString : PlotData -> String
toString (PlotData a) =
    a


concat : List PlotData -> PlotData
concat a =
    a |> List.map toString |> String.join "" |> PlotData



--


fromDmpl : Dmpl -> PlotData
fromDmpl a =
    Dmpl.toString a |> PlotData


fromHpGl : HpGl -> PlotData
fromHpGl a =
    HpGl.toString a |> PlotData


fromSumma : Summa -> PlotData
fromSumma a =
    Summa.toString a |> PlotData

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



--


fromDmpl : Dmpl -> PlotData
fromDmpl a =
    Dmpl.toString a |> PlotData


{-| Since Summa D60 gets stuck in paneling mode we need to convert HP-GL to DMPL to support paneling.
-}
fromHpGl : HpGl -> PlotData
fromHpGl a =
    Dmpl.fromHpGl a |> Dmpl.toString |> PlotData


fromSumma : Summa -> PlotData
fromSumma a =
    Summa.toString a |> PlotData

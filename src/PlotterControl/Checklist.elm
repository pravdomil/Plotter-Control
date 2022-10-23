module PlotterControl.Checklist exposing (..)


type Item
    = Depth
    | Pressure
    | Offset
    | Velocity
    | Sensitivity


items : List Item
items =
    [ Depth
    , Pressure
    , Offset
    , Velocity
    , Sensitivity
    ]


toComparable : Item -> Int
toComparable a =
    case a of
        Depth ->
            0

        Pressure ->
            1

        Offset ->
            2

        Velocity ->
            3

        Sensitivity ->
            4

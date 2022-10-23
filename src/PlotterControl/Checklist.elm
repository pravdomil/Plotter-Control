module PlotterControl.Checklist exposing (..)


type Item
    = RollAlignment
    | RollGuidesLock
    | ToolDepth
    | ToolPressure
    | ToolOffset
    | ToolVelocity
    | MarkerSensorSensitivity
    | KnifeSecureNut
    | ToolHolderKnob


items : List Item
items =
    [ RollAlignment
    , RollGuidesLock
    , ToolDepth
    , ToolPressure
    , ToolOffset
    , ToolVelocity
    , MarkerSensorSensitivity
    , KnifeSecureNut
    , ToolHolderKnob
    ]


toComparable : Item -> Int
toComparable a =
    case a of
        RollAlignment ->
            0

        RollGuidesLock ->
            1

        ToolDepth ->
            2

        ToolPressure ->
            3

        ToolOffset ->
            4

        ToolVelocity ->
            5

        MarkerSensorSensitivity ->
            6

        KnifeSecureNut ->
            7

        ToolHolderKnob ->
            8

module PlotterControl.Checklist exposing (..)


type Item
    = RollAlignment
    | RollGuidesLock
    | ToolOffset
    | ToolPressure
    | ToolDepth
    | ToolVelocity
    | MarkerSensorSensitivity
    | KnifeSecureNut
    | ToolHolderKnob


items : List Item
items =
    [ RollAlignment
    , RollGuidesLock
    , ToolOffset
    , ToolPressure
    , ToolDepth
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

        ToolOffset ->
            2

        ToolPressure ->
            3

        ToolDepth ->
            5

        ToolVelocity ->
            6

        MarkerSensorSensitivity ->
            7

        KnifeSecureNut ->
            8

        ToolHolderKnob ->
            9

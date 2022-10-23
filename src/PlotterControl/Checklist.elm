module PlotterControl.Checklist exposing (..)


type Item
    = ToolDepth
    | ToolHolderKnob
    | ToolOffset
    | ToolPressure
    | ToolVelocity
    | RollAlignment
    | RollGuidesLock
    | KnifeSecureNut
    | MarkerSensitivity
    | FlexPressure


items : List Item
items =
    [ RollAlignment
    , RollGuidesLock
    , ToolVelocity
    , ToolPressure
    , FlexPressure
    , ToolDepth
    , ToolOffset
    , KnifeSecureNut
    , ToolHolderKnob
    , MarkerSensitivity
    ]


toComparable : Item -> Int
toComparable a =
    case a of
        ToolDepth ->
            0

        ToolHolderKnob ->
            1

        ToolOffset ->
            2

        ToolPressure ->
            3

        ToolVelocity ->
            4

        RollAlignment ->
            5

        RollGuidesLock ->
            6

        KnifeSecureNut ->
            7

        MarkerSensitivity ->
            8

        FlexPressure ->
            9

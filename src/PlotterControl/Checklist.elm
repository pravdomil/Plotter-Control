module PlotterControl.Checklist exposing (..)


type Item
    = RollAlignment
    | RollGuidesLock
    | ToolPressure
    | ToolDepth
    | ToolOffset
    | FlexPressure
    | ToolVelocity
    | MarkerSensitivity
    | KnifeSecureNut
    | ToolHolderKnob


items : List Item
items =
    [ RollAlignment
    , RollGuidesLock
    , ToolPressure
    , ToolDepth
    , ToolOffset
    , FlexPressure
    , ToolVelocity
    , MarkerSensitivity
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

        ToolPressure ->
            2

        ToolDepth ->
            3

        ToolOffset ->
            4

        FlexPressure ->
            5

        ToolVelocity ->
            6

        MarkerSensitivity ->
            7

        KnifeSecureNut ->
            8

        ToolHolderKnob ->
            9

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


rollChecklist : List Item
rollChecklist =
    [ RollAlignment
    , RollGuidesLock
    ]


markersChecklist : List Item
markersChecklist =
    [ MarkerSensitivity
    ]


cutChecklist : List Item
cutChecklist =
    [ ToolVelocity
    , ToolPressure
    , ToolDepth
    , KnifeSecureNut
    , ToolHolderKnob
    , ToolOffset
    ]


perforationChecklist : List Item
perforationChecklist =
    [ ToolVelocity
    , ToolDepth
    , FlexPressure
    , KnifeSecureNut
    , ToolHolderKnob
    , ToolOffset
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

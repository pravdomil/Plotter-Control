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
    | RollerLeverArmDown
    | CutKnife
    | PerforationKnife


rollChecklist : List Item
rollChecklist =
    [ RollAlignment
    , RollGuidesLock
    , RollerLeverArmDown
    ]


mediaChecklist : List Item
mediaChecklist =
    [ MarkerSensitivity
    , ToolVelocity
    ]


cutChecklist : List Item
cutChecklist =
    [ CutKnife
    , ToolPressure
    , ToolDepth
    , KnifeSecureNut
    , ToolHolderKnob
    , ToolOffset
    ]


perforationChecklist : List Item
perforationChecklist =
    [ PerforationKnife
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

        RollerLeverArmDown ->
            10

        CutKnife ->
            11

        PerforationKnife ->
            12

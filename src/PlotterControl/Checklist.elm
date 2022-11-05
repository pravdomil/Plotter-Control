module PlotterControl.Checklist exposing (..)


type Item
    = RollRollersAlignment
    | RollGuidesLock
    | RollerLeverArmDown
      --
    | MediaToolVelocity
    | MediaMarkerSensitivity
      --
    | CutKnifeInHolder
    | CutKnifePressure
    | CutKnifeDepth
    | CutKnifeSecureNut
    | CutToolHolderKnob
    | CutKnifeOffset
      --
    | PerfKnife
    | PerfToolDepth
    | PerfFlexPressure
    | PerfKnifeSecureNut
    | PerfToolHolderKnob
    | PerfToolOffset


rollChecklist : List Item
rollChecklist =
    [ RollRollersAlignment
    , RollGuidesLock
    , RollerLeverArmDown
    ]


mediaChecklist : List Item
mediaChecklist =
    [ MediaToolVelocity
    , MediaMarkerSensitivity
    ]


cutChecklist : List Item
cutChecklist =
    [ CutKnifeInHolder
    , CutKnifePressure
    , CutKnifeDepth
    , CutKnifeSecureNut
    , CutToolHolderKnob
    , CutKnifeOffset
    ]


perforationChecklist : List Item
perforationChecklist =
    [ PerfKnife
    , PerfToolDepth
    , PerfFlexPressure
    , PerfKnifeSecureNut
    , PerfToolHolderKnob
    , PerfToolOffset
    ]


toComparable : Item -> Int
toComparable a =
    case a of
        RollRollersAlignment ->
            0

        RollGuidesLock ->
            1

        RollerLeverArmDown ->
            2

        MediaToolVelocity ->
            3

        MediaMarkerSensitivity ->
            4

        CutKnifeInHolder ->
            5

        CutKnifePressure ->
            6

        CutKnifeDepth ->
            7

        CutKnifeSecureNut ->
            8

        CutToolHolderKnob ->
            9

        CutKnifeOffset ->
            10

        PerfKnife ->
            11

        PerfToolDepth ->
            12

        PerfFlexPressure ->
            13

        PerfKnifeSecureNut ->
            14

        PerfToolHolderKnob ->
            15

        PerfToolOffset ->
            16

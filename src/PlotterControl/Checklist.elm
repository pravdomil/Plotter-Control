module PlotterControl.Checklist exposing (..)


type Item
    = LoadMediumRollersAlignment
    | LoadMediaFlangesLock
    | LoadLeverArmDown
    | LoadMediaCalibration
    | LoadToolCalibration
      --
    | MarkersTestOk
      --
    | CutKnifeInHolder
    | CutKnifePressure
    | CutKnifeDepth
    | CutKnifeSecureNut
    | CutToolHolderKnob
    | CutKnifeOffset
      --
    | PerfKnifeInHolder
    | PerfToolDepth
    | PerfFlexPressure
    | PerfKnifeSecureNut
    | PerfToolHolderKnob
    | PerfToolOffset


loadChecklist : List Item
loadChecklist =
    [ LoadMediumRollersAlignment
    , LoadMediaFlangesLock
    , LoadLeverArmDown
    , LoadMediaCalibration
    , LoadToolCalibration
    ]


markersChecklist : List Item
markersChecklist =
    [ MarkersTestOk
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
    [ PerfKnifeInHolder
    , PerfToolDepth
    , PerfFlexPressure
    , PerfKnifeSecureNut
    , PerfToolHolderKnob
    , PerfToolOffset
    ]


toComparable : Item -> Int
toComparable a =
    case a of
        LoadMediumRollersAlignment ->
            0

        LoadMediaFlangesLock ->
            1

        LoadLeverArmDown ->
            2

        LoadMediaCalibration ->
            3

        LoadToolCalibration ->
            4

        MarkersTestOk ->
            6

        CutKnifeInHolder ->
            7

        CutKnifePressure ->
            8

        CutKnifeDepth ->
            9

        CutKnifeSecureNut ->
            10

        CutToolHolderKnob ->
            11

        CutKnifeOffset ->
            12

        PerfKnifeInHolder ->
            13

        PerfToolDepth ->
            14

        PerfFlexPressure ->
            15

        PerfKnifeSecureNut ->
            16

        PerfToolHolderKnob ->
            17

        PerfToolOffset ->
            18

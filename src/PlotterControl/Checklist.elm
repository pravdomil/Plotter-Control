module PlotterControl.Checklist exposing (..)


type Item
    = LoadMediumRollersAlignment
    | LoadMediaFlangesLock
    | LoadLeverArmDown
    | LoadMarkersCalibration
    | LoadToolCalibration
      --
    | MarkersTestOk
      --
    | DrawPenInHolder
    | DrawPenPressure
    | DrawPenDepth
    | DrawToolHolderKnob
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
    , LoadMarkersCalibration
    , LoadToolCalibration
    ]


markersChecklist : List Item
markersChecklist =
    [ MarkersTestOk
    ]


drawChecklist : List Item
drawChecklist =
    [ CutKnifeInHolder
    , CutKnifePressure
    , CutKnifeDepth
    , CutKnifeSecureNut
    , CutToolHolderKnob
    , CutKnifeOffset
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


toComparable : Item -> String
toComparable a =
    case a of
        LoadMediumRollersAlignment ->
            "LoadMediumRollersAlignment"

        LoadMediaFlangesLock ->
            "LoadMediaFlangesLock"

        LoadLeverArmDown ->
            "LoadLeverArmDown"

        LoadMarkersCalibration ->
            "LoadMarkersCalibration"

        LoadToolCalibration ->
            "LoadToolCalibration"

        MarkersTestOk ->
            "MarkersTestOk"

        DrawPenInHolder ->
            "DrawPenInHolder"

        DrawPenPressure ->
            "DrawPenPressure"

        DrawPenDepth ->
            "DrawPenDepth"

        DrawToolHolderKnob ->
            "DrawToolHolderKnob"

        CutKnifeInHolder ->
            "CutKnifeInHolder"

        CutKnifePressure ->
            "CutKnifePressure"

        CutKnifeDepth ->
            "CutKnifeDepth"

        CutKnifeSecureNut ->
            "CutKnifeSecureNut"

        CutToolHolderKnob ->
            "CutToolHolderKnob"

        CutKnifeOffset ->
            "CutKnifeOffset"

        PerfKnifeInHolder ->
            "PerfKnifeInHolder"

        PerfToolDepth ->
            "PerfToolDepth"

        PerfFlexPressure ->
            "PerfFlexPressure"

        PerfKnifeSecureNut ->
            "PerfKnifeSecureNut"

        PerfToolHolderKnob ->
            "PerfToolHolderKnob"

        PerfToolOffset ->
            "PerfToolOffset"

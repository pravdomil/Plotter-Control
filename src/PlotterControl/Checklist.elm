module PlotterControl.Checklist exposing (..)


type Checklist
    = MediaChecklist
    | MarkersChecklist
    | DrawingChecklist
    | CuttingChecklist
    | PerforationChecklist


all : List Checklist
all =
    [ MediaChecklist
    , MarkersChecklist
    , DrawingChecklist
    , CuttingChecklist
    , PerforationChecklist
    ]



--


type Item
    = MediaRollersAlignment
    | MediaFlangeGuides
    | MediaLeverArmDown
    | MediaMarkersCalibration
    | MediaPresetCalibration
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


mediaChecklist : List Item
mediaChecklist =
    [ MediaRollersAlignment
    , MediaFlangeGuides
    , MediaLeverArmDown
    , MediaMarkersCalibration
    , MediaPresetCalibration
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
        MediaRollersAlignment ->
            "MediaRollersAlignment"

        MediaFlangeGuides ->
            "MediaFlangeGuides"

        MediaLeverArmDown ->
            "MediaLeverArmDown"

        MediaMarkersCalibration ->
            "MediaMarkersCalibration"

        MediaPresetCalibration ->
            "MediaPresetCalibration"

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

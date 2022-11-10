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
    | DrawingPenInHolder
    | DrawingPenPressure
    | DrawingPenDepth
    | DrawingToolHolderKnob
      --
    | CuttingKnifeInHolder
    | CuttingKnifePressure
    | CuttingKnifeDepth
    | CuttingKnifeSecureNut
    | CuttingToolHolderKnob
    | CuttingKnifeOffset
      --
    | PerforationKnifeInHolder
    | PerforationToolDepth
    | PerforationFlexPressure
    | PerforationKnifeSecureNut
    | PerforationToolHolderKnob
    | PerforationToolOffset


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


drawingChecklist : List Item
drawingChecklist =
    [ CuttingKnifeInHolder
    , CuttingKnifePressure
    , CuttingKnifeDepth
    , CuttingKnifeSecureNut
    , CuttingToolHolderKnob
    , CuttingKnifeOffset
    ]


cuttingChecklist : List Item
cuttingChecklist =
    [ CuttingKnifeInHolder
    , CuttingKnifePressure
    , CuttingKnifeDepth
    , CuttingKnifeSecureNut
    , CuttingToolHolderKnob
    , CuttingKnifeOffset
    ]


perforationChecklist : List Item
perforationChecklist =
    [ PerforationKnifeInHolder
    , PerforationToolDepth
    , PerforationFlexPressure
    , PerforationKnifeSecureNut
    , PerforationToolHolderKnob
    , PerforationToolOffset
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

        DrawingPenInHolder ->
            "DrawingPenInHolder"

        DrawingPenPressure ->
            "DrawingPenPressure"

        DrawingPenDepth ->
            "DrawingPenDepth"

        DrawingToolHolderKnob ->
            "DrawingToolHolderKnob"

        CuttingKnifeInHolder ->
            "CuttingKnifeInHolder"

        CuttingKnifePressure ->
            "CuttingKnifePressure"

        CuttingKnifeDepth ->
            "CuttingKnifeDepth"

        CuttingKnifeSecureNut ->
            "CuttingKnifeSecureNut"

        CuttingToolHolderKnob ->
            "CuttingToolHolderKnob"

        CuttingKnifeOffset ->
            "CuttingKnifeOffset"

        PerforationKnifeInHolder ->
            "PerforationKnifeInHolder"

        PerforationToolDepth ->
            "PerforationToolDepth"

        PerforationFlexPressure ->
            "PerforationFlexPressure"

        PerforationKnifeSecureNut ->
            "PerforationKnifeSecureNut"

        PerforationToolHolderKnob ->
            "PerforationToolHolderKnob"

        PerforationToolOffset ->
            "PerforationToolOffset"

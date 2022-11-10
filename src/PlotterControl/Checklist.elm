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


items : Checklist -> List Item
items a =
    case a of
        MediaChecklist ->
            mediaItems

        MarkersChecklist ->
            markersItems

        DrawingChecklist ->
            drawingItems

        CuttingChecklist ->
            cuttingItems

        PerforationChecklist ->
            perforationItems



--


type Item
    = MediaRollersInRange
    | MediaRollersAlignment
    | MediaFlangeGuides
    | MediaLeverArmDown
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


mediaItems : List Item
mediaItems =
    [ MediaRollersInRange
    , MediaRollersAlignment
    , MediaFlangeGuides
    , MediaLeverArmDown
    ]


markersItems : List Item
markersItems =
    [ MarkersTestOk
    ]


drawingItems : List Item
drawingItems =
    [ CuttingKnifeInHolder
    , CuttingKnifePressure
    , CuttingKnifeDepth
    , CuttingKnifeSecureNut
    , CuttingToolHolderKnob
    , CuttingKnifeOffset
    ]


cuttingItems : List Item
cuttingItems =
    [ CuttingKnifeInHolder
    , CuttingKnifePressure
    , CuttingKnifeDepth
    , CuttingKnifeSecureNut
    , CuttingToolHolderKnob
    , CuttingKnifeOffset
    ]


perforationItems : List Item
perforationItems =
    [ PerforationKnifeInHolder
    , PerforationToolDepth
    , PerforationFlexPressure
    , PerforationKnifeSecureNut
    , PerforationToolHolderKnob
    , PerforationToolOffset
    ]


itemToComparable : Item -> String
itemToComparable a =
    case a of
        MediaRollersInRange ->
            "MediaRollersInRange"

        MediaRollersAlignment ->
            "MediaRollersAlignment"

        MediaFlangeGuides ->
            "MediaFlangeGuides"

        MediaLeverArmDown ->
            "MediaLeverArmDown"

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

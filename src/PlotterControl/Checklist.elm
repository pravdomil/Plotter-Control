module PlotterControl.Checklist exposing (..)


type Checklist
    = Media
    | Markers
    | Drawing
    | Cutting
    | Perforation


toName : Checklist -> String
toName a =
    case a of
        Media ->
            "Media"

        Markers ->
            "Markers"

        Drawing ->
            "Drawing"

        Cutting ->
            "Cutting"

        Perforation ->
            "Perforation"


all : List Checklist
all =
    [ Media
    , Markers
    , Drawing
    , Cutting
    , Perforation
    ]


items : Checklist -> List Item
items a =
    case a of
        Media ->
            mediaItems

        Markers ->
            markersItems

        Drawing ->
            drawingItems

        Cutting ->
            cuttingItems

        Perforation ->
            perforationItems



--


type Item
    = MediaRollersInRange
    | MediaRollersAlignment
    | MediaFlangeGuides
    | MediaLeverArmDown
      --
    | MarkersSensorClean
    | MarkersTestOk
      --
    | DrawingPenInHolder
    | DrawingSpeed
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
    [ MarkersSensorClean
    , MarkersTestOk
    ]


drawingItems : List Item
drawingItems =
    [ DrawingPenInHolder
    , DrawingSpeed
    , DrawingPenPressure
    , DrawingPenDepth
    , DrawingToolHolderKnob
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

        MarkersSensorClean ->
            "MarkersSensorClean"

        MarkersTestOk ->
            "MarkersTestOk"

        DrawingPenInHolder ->
            "DrawingPenInHolder"

        DrawingSpeed ->
            "DrawingSpeed"

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

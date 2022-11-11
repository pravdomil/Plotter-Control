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
    | DrawingPenDepth
    | DrawingToolHolderKnob
    | DrawingTestOk
      --
    | CuttingKnifeInHolder
    | CuttingKnifeDepth
    | CuttingKnifeSecureNut
    | CuttingToolHolderKnob
    | CuttingTestOk
      --
    | PerforationKnifeInHolder
    | PerforationToolDepth
    | PerforationKnifeSecureNut
    | PerforationToolHolderKnob
    | PerforationTestOk


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
    , DrawingPenDepth
    , DrawingToolHolderKnob
    , DrawingTestOk
    ]


cuttingItems : List Item
cuttingItems =
    [ CuttingKnifeInHolder
    , CuttingKnifeDepth
    , CuttingKnifeSecureNut
    , CuttingToolHolderKnob
    , CuttingTestOk
    ]


perforationItems : List Item
perforationItems =
    [ PerforationKnifeInHolder
    , PerforationToolDepth
    , PerforationKnifeSecureNut
    , PerforationToolHolderKnob
    , PerforationTestOk
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

        DrawingPenDepth ->
            "DrawingPenDepth"

        DrawingToolHolderKnob ->
            "DrawingToolHolderKnob"

        DrawingTestOk ->
            "DrawingTestOk"

        CuttingKnifeInHolder ->
            "CuttingKnifeInHolder"

        CuttingKnifeDepth ->
            "CuttingKnifeDepth"

        CuttingKnifeSecureNut ->
            "CuttingKnifeSecureNut"

        CuttingToolHolderKnob ->
            "CuttingToolHolderKnob"

        CuttingTestOk ->
            "CuttingTestOk"

        PerforationKnifeInHolder ->
            "PerforationKnifeInHolder"

        PerforationToolDepth ->
            "PerforationToolDepth"

        PerforationKnifeSecureNut ->
            "PerforationKnifeSecureNut"

        PerforationToolHolderKnob ->
            "PerforationToolHolderKnob"

        PerforationTestOk ->
            "PerforationTestOk"

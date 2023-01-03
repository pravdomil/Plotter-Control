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
    | DrawingTestOk
    | DrawingToolHolderKnob
      --
    | CuttingKnifeInHolder
    | CuttingKnifeDepth
    | CuttingTestOk
    | CuttingKnifeSecureNut
    | CuttingToolHolderKnob
      --
    | PerforationKnifeInHolder
    | PerforationTestOk
    | PerforationKnifeSecureNut
    | PerforationToolHolderKnob


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
    , DrawingTestOk
    , DrawingToolHolderKnob
    ]


cuttingItems : List Item
cuttingItems =
    [ CuttingKnifeInHolder
    , CuttingKnifeDepth
    , CuttingTestOk
    , CuttingKnifeSecureNut
    , CuttingToolHolderKnob
    ]


perforationItems : List Item
perforationItems =
    [ PerforationKnifeInHolder
    , PerforationTestOk
    , PerforationKnifeSecureNut
    , PerforationToolHolderKnob
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

        PerforationKnifeSecureNut ->
            "PerforationKnifeSecureNut"

        PerforationToolHolderKnob ->
            "PerforationToolHolderKnob"

        PerforationTestOk ->
            "PerforationTestOk"

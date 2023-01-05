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
    | DrawingTestOk
      --
    | CuttingKnifeInHolder
    | CuttingTestOk
    | CuttingKnifeSecureNut
      --
    | PerforationKnifeInHolder
    | PerforationTestOk
    | PerforationKnifeSecureNut


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
    , DrawingTestOk
    ]


cuttingItems : List Item
cuttingItems =
    [ CuttingKnifeInHolder
    , CuttingTestOk
    , CuttingKnifeSecureNut
    ]


perforationItems : List Item
perforationItems =
    [ PerforationKnifeInHolder
    , PerforationTestOk
    , PerforationKnifeSecureNut
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

        DrawingTestOk ->
            "DrawingTestOk"

        CuttingKnifeInHolder ->
            "CuttingKnifeInHolder"

        CuttingKnifeSecureNut ->
            "CuttingKnifeSecureNut"

        CuttingTestOk ->
            "CuttingTestOk"

        PerforationKnifeInHolder ->
            "PerforationKnifeInHolder"

        PerforationKnifeSecureNut ->
            "PerforationKnifeSecureNut"

        PerforationTestOk ->
            "PerforationTestOk"

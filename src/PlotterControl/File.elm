module PlotterControl.File exposing (..)

import BoundingBox2d
import Dict
import File
import HP_GL
import HP_GL.Geometry
import Length
import Parser
import Polyline2d
import Quantity
import SummaEL


type alias File =
    { name : Name
    , polylines : List (Polyline2d.Polyline2d Length.Meters ())
    , markers : Maybe Markers
    }


fromFile : File.File -> String -> Result Error File
fromFile a b =
    if a |> File.name |> String.endsWith ".hpgl" then
        fromHP_GLFile a b

    else
        Err FileNotSupported


fromHP_GLFile : File.File -> String -> Result Error File
fromHP_GLFile a b =
    b
        |> HP_GL.fromString
        |> Result.mapError ParserError
        |> Result.map HP_GL.Geometry.polylines
        |> Result.andThen filterMarkers
        |> Result.map
            (\( polylines, markers ) ->
                { name = a |> File.name |> Name
                , polylines = polylines
                , markers = markers
                }
            )


toCommands : File -> ( SummaEL.SummaEL, HP_GL.HP_GL )
toCommands a =
    ( case a.markers of
        Just b ->
            [ SummaEL.SetSettings
                (Dict.fromList
                    [ ( "MARKER_X_DIS", b.xDistance |> HP_GL.lengthToString )
                    , ( "MARKER_Y_DIS", b.yDistance |> HP_GL.lengthToString )
                    , ( "MARKER_X_SIZE", markerSize |> HP_GL.lengthToString )
                    , ( "MARKER_Y_SIZE", markerSize |> HP_GL.lengthToString )
                    , ( "MARKER_X_N", b.count |> String.fromInt )
                    ]
                )
            , SummaEL.LoadMarkers
            ]

        Nothing ->
            []
    , a.polylines
        |> HP_GL.Geometry.fromPolylines
        |> (\v -> [ HP_GL.Initialize ] ++ v ++ [ HP_GL.End ])
    )



--


type Name
    = Name String



--


type alias Markers =
    { xDistance : Length.Length
    , yDistance : Length.Length
    , count : Int
    }


markerSize : Length.Length
markerSize =
    Length.millimeters 3





--


type Error
    = FileNotSupported
    | InvalidMarkerCount
    | ParserError (List Parser.DeadEnd)

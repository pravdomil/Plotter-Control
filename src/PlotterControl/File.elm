module PlotterControl.File exposing (..)

import Dict
import File
import HpGl
import HpGl.Geometry
import Length
import Parser
import PlotterControl.Markers
import PlotterControl.Settings
import Polyline2d
import SummaEl
import Task
import Time


type alias File =
    { ready : Result Error Ready

    --
    , created : Time.Posix
    }


fromFile : File.File -> Task.Task x ( Name, File )
fromFile a =
    Task.map2
        (\x x2 ->
            ( stringToName (String.dropRight (String.length supportedExtension) (File.name a))
            , File x x2
            )
        )
        (if a |> File.name |> String.endsWith supportedExtension then
            hpGlFileToReady a

         else
            Task.succeed (Err FileNotSupported)
        )
        Time.now


supportedExtension : String
supportedExtension =
    ".hpgl"



--


type Name
    = Name String


stringToName : String -> Name
stringToName =
    Name


nameToString : Name -> String
nameToString (Name a) =
    a



--


type alias Ready =
    { polylines : List (Polyline2d.Polyline2d Length.Meters ())
    , markers : Maybe PlotterControl.Markers.Markers
    , settings : PlotterControl.Settings.Settings
    }


hpGlFileToReady : File.File -> Task.Task x (Result Error Ready)
hpGlFileToReady a =
    a
        |> File.toString
        |> Task.map
            (\x ->
                x
                    |> HpGl.fromString
                    |> Result.mapError ParserError
                    |> Result.map HpGl.Geometry.polylines
                    |> Result.andThen (PlotterControl.Markers.fromPolylines >> Result.mapError MarkersError)
                    |> Result.map
                        (\( polylines, markers ) ->
                            Ready
                                polylines
                                markers
                                (PlotterControl.Settings.default (File.name a))
                        )
            )


readySettingsToSummaEl : Ready -> SummaEl.SummaEl
readySettingsToSummaEl a =
    PlotterControl.Settings.toCommandAndSettings a.settings
        |> Tuple.mapSecond
            (\x ->
                case a.markers of
                    Just x2 ->
                        Dict.union (PlotterControl.Markers.toSettings x2) x

                    Nothing ->
                        x
            )
        |> (\( x, x2 ) ->
                x
                    ++ [ SummaEl.SetSettings x2
                       ]
           )


readyToPlotterData : Ready -> String
readyToPlotterData a =
    let
        setSettings : String
        setSettings =
            SummaEl.toString (readySettingsToSummaEl a)

        maybeLoadMarkers : String
        maybeLoadMarkers =
            case a.markers of
                Just _ ->
                    SummaEl.toString
                        [ SummaEl.LoadMarkers
                        ]

                Nothing ->
                    ""

        data : String
        data =
            a.polylines
                |> HpGl.Geometry.fromPolylines
                |> (\x -> HpGl.Initialize :: x ++ [ HpGl.End ])
                |> HpGl.toString

        maybeRecut : String
        maybeRecut =
            a.settings.copies
                |> PlotterControl.Settings.copiesToInt
                |> (\x ->
                        if x > 1 then
                            SummaEl.toString
                                [ SummaEl.Recut (x - 1)
                                ]

                        else
                            ""
                   )
    in
    String.join "\n"
        [ setSettings
        , maybeLoadMarkers
        , data
        , maybeRecut
        ]



--


type Error
    = FileNotSupported
    | ParserError (List Parser.DeadEnd)
    | MarkersError PlotterControl.Markers.Error

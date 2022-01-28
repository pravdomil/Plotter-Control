module HP_GL.Geometry exposing (..)

import HP_GL
import Length
import Point2d
import Polyline2d


polylines : HP_GL.HP_GL -> List (Polyline2d.Polyline2d Length.Meters ())
polylines a =
    let
        fold :
            HP_GL.Command
            -> List (List (Point2d.Point2d Length.Meters ()))
            -> List (List (Point2d.Point2d Length.Meters ()))
        fold b acc =
            case b of
                HP_GL.ToolDown points ->
                    case acc of
                        [] ->
                            [ points
                            ]

                        c :: rest ->
                            (points ++ c) :: rest

                HP_GL.ToolUp points ->
                    case points |> List.reverse |> List.head of
                        Just last ->
                            [ last ] :: acc

                        Nothing ->
                            acc

                _ ->
                    [] :: acc
    in
    a
        |> List.foldl fold []
        |> List.filterMap
            (\v ->
                if List.length v < 2 then
                    Nothing

                else
                    v |> List.reverse |> Polyline2d.fromVertices |> Just
            )
        |> List.reverse


fromPolylines : List (Polyline2d.Polyline2d Length.Meters ()) -> HP_GL.HP_GL
fromPolylines a =
    let
        toCommands : Polyline2d.Polyline2d Length.Meters () -> HP_GL.HP_GL
        toCommands b =
            case b |> Polyline2d.vertices of
                [] ->
                    []

                first :: rest ->
                    [ HP_GL.ToolUp [ first ]
                    , HP_GL.ToolDown rest
                    ]
    in
    a |> List.concatMap toCommands

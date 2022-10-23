module HpGl.Geometry exposing (..)

import HpGl
import Length
import Point2d
import Polyline2d


polylines : HpGl.HpGl -> List (Polyline2d.Polyline2d Length.Meters ())
polylines a =
    let
        fold :
            HpGl.Command
            -> List (List (Point2d.Point2d Length.Meters ()))
            -> List (List (Point2d.Point2d Length.Meters ()))
        fold b acc =
            case b of
                HpGl.ToolDown points ->
                    case acc of
                        [] ->
                            [ points
                            ]

                        c :: rest ->
                            (points ++ c) :: rest

                HpGl.ToolUp points ->
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
            (\x ->
                if List.length x < 2 then
                    Nothing

                else
                    x |> List.reverse |> Polyline2d.fromVertices |> Just
            )
        |> List.reverse


fromPolylines : List (Polyline2d.Polyline2d Length.Meters ()) -> HpGl.HpGl
fromPolylines a =
    let
        toCommands : Polyline2d.Polyline2d Length.Meters () -> HpGl.HpGl
        toCommands b =
            case b |> Polyline2d.vertices of
                [] ->
                    []

                first :: rest ->
                    [ HpGl.ToolUp [ first ]
                    , HpGl.ToolDown rest
                    ]
    in
    a |> List.concatMap toCommands

module Utils.RegistrationMark exposing (..)

import String exposing (split)
import Utils.Command exposing (Command(..), commandsToString, offsetBy, scaleBy, stepSize)
import Utils.Utils exposing (Point)


{-| To get registration mark size in mm.
-}
registrationMarkSize : number
registrationMarkSize =
    12


{-| To get registration marks coordinates.
-}
registrationMarks : List Point
registrationMarks =
    List.range 0 1
        |> List.concatMap
            (\a ->
                List.range 0 9
                    |> List.concatMap
                        (\b ->
                            List.range 0 3
                                |> List.map
                                    (\c ->
                                        ( toFloat a * 550, toFloat b * 100 + toFloat c * registrationMarkSize )
                                    )
                        )
            )


registrationMark =
    let
        _ =
            horizontalRegistrationMark
                |> List.map (offsetBy ( 0, 2.5 ))
                |> commandsToString
                |> Debug.log "log"

        _ =
            """

        PU104,4
        PD104,484
        PU144,4
        PD144,484
        PU184,4
        PD184,484
        PU224,4
        PD224,484
        PU264,4
        PD264,484
        PU304,4
        PD304,484
        PU344,4
        PD344,484
        PU384,4
        PD384,484
        PU424,4
        PD424,484
        PU464,4
        PD464,484
        """
                |> split "\n"
                |> List.map String.trim
                |> List.filter (String.isEmpty >> not)
                |> List.filterMap
                    (\v ->
                        let
                            parsePoint : String -> Maybe Point
                            parsePoint a =
                                case a |> String.dropLeft 2 |> split "," of
                                    x :: y :: [] ->
                                        case ( String.toFloat x, String.toFloat y ) of
                                            ( Just xx, Just yy ) ->
                                                Just ( yy, xx )

                                            _ ->
                                                Nothing

                                    _ ->
                                        Nothing
                        in
                        case v |> String.left 2 of
                            "PU" ->
                                v |> parsePoint |> Maybe.map (\( x, y ) -> LineStart x y)

                            "PD" ->
                                v |> parsePoint |> Maybe.map (\( x, y ) -> LineTo x y)

                            _ ->
                                Nothing
                    )
                |> (\v -> v ++ [ LineEnd ])
                |> List.map
                    (\v ->
                        v
                            |> scaleBy ( stepSize, stepSize )
                            |> offsetBy ( -0.1, -0.1 )
                            |> offsetBy ( 0, -2.5 )
                    )
    in
    []


{-| Foo
-}
horizontalRegistrationMark =
    [ LineStart 0 0
    , LineTo 12 0
    , LineStart 0 1
    , LineTo 12 1
    , LineStart 0 2
    , LineTo 12 2
    , LineStart 0 3
    , LineTo 12 3
    , LineStart 0 4
    , LineTo 12 4
    , LineStart 0 5
    , LineTo 12 5
    , LineStart 0 6
    , LineTo 12 6
    , LineStart 0 7
    , LineTo 12 7
    , LineStart 0 8
    , LineTo 12 8
    , LineStart 0 9
    , LineTo 12 9
    , LineEnd
    ]
        |> List.map (offsetBy ( 0.1, 0.1 ))


{-| Foo
-}
verticalRegistrationMark =
    [ LineStart 0 0
    , LineTo 0 12
    , LineStart 1 0
    , LineTo 1 12
    , LineStart 2 0
    , LineTo 2 12
    , LineStart 3 0
    , LineTo 3 12
    , LineStart 4 0
    , LineTo 4 12
    , LineStart 5 0
    , LineTo 5 12
    , LineStart 6 0
    , LineTo 6 12
    , LineStart 7 0
    , LineTo 7 12
    , LineStart 8 0
    , LineTo 8 12
    , LineStart 9 0
    , LineTo 9 12
    , LineEnd
    ]
        |> List.map (offsetBy ( 0.1, 0.1 ))

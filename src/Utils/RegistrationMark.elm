module Utils.RegistrationMark exposing (..)

import Utils.Command exposing (Command(..))
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


{-| To get commands for plotting registration mark.
-}
registrationMark : List Command
registrationMark =
    [ MoveTo 4 104
    , LineTo 124 104
    , MoveTo 144 4
    , LineTo 144 124
    , MoveTo 104 4
    , LineTo 104 124
    , MoveTo 4 144
    , LineTo 124 144
    , MoveTo 4 184
    , LineTo 124 184
    , MoveTo 4 224
    , LineTo 124 224
    , MoveTo 4 264
    , LineTo 124 264
    , MoveTo 4 304
    , LineTo 124 304
    , MoveTo 4 344
    , LineTo 124 344
    , MoveTo 4 384
    , LineTo 124 384
    , MoveTo 4 424
    , LineTo 124 424
    , MoveTo 4 464
    , LineTo 124 464
    , MoveTo 184 4
    , LineTo 184 124
    , MoveTo 224 4
    , LineTo 224 124
    , MoveTo 264 4
    , LineTo 264 124
    , MoveTo 304 4
    , LineTo 304 124
    , MoveTo 344 4
    , LineTo 344 124
    , MoveTo 384 4
    , LineTo 384 124
    , MoveTo 424 4
    , LineTo 424 124
    , MoveTo 464 4
    , LineTo 464 124
    , LineEnd
    ]

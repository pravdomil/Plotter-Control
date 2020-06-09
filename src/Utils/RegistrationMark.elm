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
    [ PU2 4 104
    , PD 124 104
    , PU2 144 4
    , PD 144 124
    , PU2 104 4
    , PD 104 124
    , PU2 4 144
    , PD 124 144
    , PU2 4 184
    , PD 124 184
    , PU2 4 224
    , PD 124 224
    , PU2 4 264
    , PD 124 264
    , PU2 4 304
    , PD 124 304
    , PU2 4 344
    , PD 124 344
    , PU2 4 384
    , PD 124 384
    , PU2 4 424
    , PD 124 424
    , PU2 4 464
    , PD 124 464
    , PU2 184 4
    , PD 184 124
    , PU2 224 4
    , PD 224 124
    , PU2 264 4
    , PD 264 124
    , PU2 304 4
    , PD 304 124
    , PU2 344 4
    , PD 344 124
    , PU2 384 4
    , PD 384 124
    , PU2 424 4
    , PD 424 124
    , PU2 464 4
    , PD 464 124
    , PU
    ]

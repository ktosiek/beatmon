module Utils.List exposing (ifTrue)


ifTrue : Bool -> a -> List a
ifTrue bool a =
    if bool then
        [ a ]

    else
        []

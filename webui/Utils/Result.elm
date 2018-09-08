module Utils.Result exposing (merge)


merge : Result a a -> a
merge r =
    case r of
        Ok a ->
            a

        Err a ->
            a

module Utils.Result exposing (merge, pushMaybe)


merge : Result a a -> a
merge r =
    case r of
        Ok a ->
            a

        Err a ->
            a


pushMaybe : Maybe (Result e a) -> Result e (Maybe a)
pushMaybe r =
    case r of
        Just res ->
            res |> Result.map Just

        Nothing ->
            Ok Nothing

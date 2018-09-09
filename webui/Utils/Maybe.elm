module Utils.Maybe exposing (apply)


apply : Maybe a -> (a -> b -> b) -> b -> b
apply m f =
    case m of
        Nothing ->
            identity

        Just a ->
            f a

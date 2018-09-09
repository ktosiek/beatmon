module Utils.Browser.Document exposing (map)

import Browser exposing (Document)
import Html


map : (a -> b) -> Document a -> Document b
map f { title, body } =
    { title = title
    , body = List.map (Html.map f) body
    }

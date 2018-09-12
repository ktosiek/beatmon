module Pages.Common exposing (Context, basicLayout)

import Html
import Html.Events exposing (onClick)
import Model exposing (Msg(..))


type alias Context a =
    a


basicLayout ctx content =
    Html.div []
        [ Html.div []
            [ Html.button [ onClick LogOut ] [ Html.text "Log out" ]
            ]
        , Html.div [] [ content ]
        ]

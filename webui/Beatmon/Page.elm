module Beatmon.Page exposing (Cursor, Page, fromApiCursor, hasNext, toApiCursor)

import Beatmon.Api.Scalar as Api
import Maybe.Extra as Maybe


type alias Page a =
    { endCursor : Maybe (Cursor a)
    , nodes : List a
    }


type Cursor a
    = Cursor Api.Cursor


hasNext : Page a -> Bool
hasNext { endCursor } =
    Maybe.isJust endCursor


toApiCursor : Cursor a -> Api.Cursor
toApiCursor (Cursor c) =
    c


fromApiCursor : Api.Cursor -> Cursor a
fromApiCursor c =
    Cursor c

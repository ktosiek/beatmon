-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Beatmon.Api.Object.PageInfo exposing (endCursor, hasNextPage, hasPreviousPage, selection, startCursor)

import Beatmon.Api.InputObject
import Beatmon.Api.Interface
import Beatmon.Api.Object
import Beatmon.Api.Scalar
import Beatmon.Api.Union
import Graphql.Field as Field exposing (Field)
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


{-| Select fields to build up a SelectionSet for this object.
-}
selection : (a -> constructor) -> SelectionSet (a -> constructor) Beatmon.Api.Object.PageInfo
selection constructor =
    Object.selection constructor


{-| When paginating forwards, are there more items?
-}
hasNextPage : Field Bool Beatmon.Api.Object.PageInfo
hasNextPage =
    Object.fieldDecoder "hasNextPage" [] Decode.bool


{-| When paginating backwards, are there more items?
-}
hasPreviousPage : Field Bool Beatmon.Api.Object.PageInfo
hasPreviousPage =
    Object.fieldDecoder "hasPreviousPage" [] Decode.bool


{-| When paginating backwards, the cursor to continue.
-}
startCursor : Field (Maybe Beatmon.Api.Scalar.Cursor) Beatmon.Api.Object.PageInfo
startCursor =
    Object.fieldDecoder "startCursor" [] (Object.scalarDecoder |> Decode.map Beatmon.Api.Scalar.Cursor |> Decode.nullable)


{-| When paginating forwards, the cursor to continue.
-}
endCursor : Field (Maybe Beatmon.Api.Scalar.Cursor) Beatmon.Api.Object.PageInfo
endCursor =
    Object.fieldDecoder "endCursor" [] (Object.scalarDecoder |> Decode.map Beatmon.Api.Scalar.Cursor |> Decode.nullable)
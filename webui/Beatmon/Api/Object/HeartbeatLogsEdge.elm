-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Beatmon.Api.Object.HeartbeatLogsEdge exposing (cursor, node, selection)

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
selection : (a -> constructor) -> SelectionSet (a -> constructor) Beatmon.Api.Object.HeartbeatLogsEdge
selection constructor =
    Object.selection constructor


{-| A cursor for use in pagination.
-}
cursor : Field (Maybe Beatmon.Api.Scalar.Cursor) Beatmon.Api.Object.HeartbeatLogsEdge
cursor =
    Object.fieldDecoder "cursor" [] (Object.scalarDecoder |> Decode.map Beatmon.Api.Scalar.Cursor |> Decode.nullable)


{-| The `HeartbeatLog` at the end of the edge.
-}
node : SelectionSet decodesTo Beatmon.Api.Object.HeartbeatLog -> Field (Maybe decodesTo) Beatmon.Api.Object.HeartbeatLogsEdge
node object_ =
    Object.selectionField "node" [] object_ (identity >> Decode.nullable)

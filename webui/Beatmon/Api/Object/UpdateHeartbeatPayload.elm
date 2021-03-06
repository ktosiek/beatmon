-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Beatmon.Api.Object.UpdateHeartbeatPayload exposing (HeartbeatEdgeOptionalArguments, accountByAccountId, clientMutationId, heartbeat, heartbeatEdge, query, selection)

import Beatmon.Api.Enum.HeartbeatsOrderBy
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
selection : (a -> constructor) -> SelectionSet (a -> constructor) Beatmon.Api.Object.UpdateHeartbeatPayload
selection constructor =
    Object.selection constructor


{-| The exact same `clientMutationId` that was provided in the mutation input, unchanged and unused. May be used by a client to track mutations.
-}
clientMutationId : Field (Maybe String) Beatmon.Api.Object.UpdateHeartbeatPayload
clientMutationId =
    Object.fieldDecoder "clientMutationId" [] (Decode.string |> Decode.nullable)


{-| The `Heartbeat` that was updated by this mutation.
-}
heartbeat : SelectionSet decodesTo Beatmon.Api.Object.Heartbeat -> Field (Maybe decodesTo) Beatmon.Api.Object.UpdateHeartbeatPayload
heartbeat object_ =
    Object.selectionField "heartbeat" [] object_ (identity >> Decode.nullable)


{-| Our root query field type. Allows us to run any query from our mutation payload.
-}
query : SelectionSet decodesTo RootQuery -> Field (Maybe decodesTo) Beatmon.Api.Object.UpdateHeartbeatPayload
query object_ =
    Object.selectionField "query" [] object_ (identity >> Decode.nullable)


{-| Reads a single `Account` that is related to this `Heartbeat`.
-}
accountByAccountId : SelectionSet decodesTo Beatmon.Api.Object.Account -> Field (Maybe decodesTo) Beatmon.Api.Object.UpdateHeartbeatPayload
accountByAccountId object_ =
    Object.selectionField "accountByAccountId" [] object_ (identity >> Decode.nullable)


type alias HeartbeatEdgeOptionalArguments =
    { orderBy : OptionalArgument (List Beatmon.Api.Enum.HeartbeatsOrderBy.HeartbeatsOrderBy) }


{-| An edge for our `Heartbeat`. May be used by Relay 1.

  - orderBy - The method to use when ordering `Heartbeat`.

-}
heartbeatEdge : (HeartbeatEdgeOptionalArguments -> HeartbeatEdgeOptionalArguments) -> SelectionSet decodesTo Beatmon.Api.Object.HeartbeatsEdge -> Field (Maybe decodesTo) Beatmon.Api.Object.UpdateHeartbeatPayload
heartbeatEdge fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { orderBy = Absent }

        optionalArgs =
            [ Argument.optional "orderBy" filledInOptionals.orderBy (Encode.enum Beatmon.Api.Enum.HeartbeatsOrderBy.toString |> Encode.list) ]
                |> List.filterMap identity
    in
    Object.selectionField "heartbeatEdge" optionalArgs object_ (identity >> Decode.nullable)

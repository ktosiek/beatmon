-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Beatmon.Api.Object.CreateHeartbeatLogPayload exposing (HeartbeatLogEdgeOptionalArguments, clientMutationId, heartbeatByHeartbeatIdAndAccountId, heartbeatLog, heartbeatLogEdge, query, selection)

import Beatmon.Api.Enum.HeartbeatLogsOrderBy
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
selection : (a -> constructor) -> SelectionSet (a -> constructor) Beatmon.Api.Object.CreateHeartbeatLogPayload
selection constructor =
    Object.selection constructor


{-| The exact same `clientMutationId` that was provided in the mutation input, unchanged and unused. May be used by a client to track mutations.
-}
clientMutationId : Field (Maybe String) Beatmon.Api.Object.CreateHeartbeatLogPayload
clientMutationId =
    Object.fieldDecoder "clientMutationId" [] (Decode.string |> Decode.nullable)


{-| The `HeartbeatLog` that was created by this mutation.
-}
heartbeatLog : SelectionSet decodesTo Beatmon.Api.Object.HeartbeatLog -> Field (Maybe decodesTo) Beatmon.Api.Object.CreateHeartbeatLogPayload
heartbeatLog object_ =
    Object.selectionField "heartbeatLog" [] object_ (identity >> Decode.nullable)


{-| Our root query field type. Allows us to run any query from our mutation payload.
-}
query : SelectionSet decodesTo RootQuery -> Field (Maybe decodesTo) Beatmon.Api.Object.CreateHeartbeatLogPayload
query object_ =
    Object.selectionField "query" [] object_ (identity >> Decode.nullable)


{-| Reads a single `Heartbeat` that is related to this `HeartbeatLog`.
-}
heartbeatByHeartbeatIdAndAccountId : SelectionSet decodesTo Beatmon.Api.Object.Heartbeat -> Field (Maybe decodesTo) Beatmon.Api.Object.CreateHeartbeatLogPayload
heartbeatByHeartbeatIdAndAccountId object_ =
    Object.selectionField "heartbeatByHeartbeatIdAndAccountId" [] object_ (identity >> Decode.nullable)


type alias HeartbeatLogEdgeOptionalArguments =
    { orderBy : OptionalArgument (List Beatmon.Api.Enum.HeartbeatLogsOrderBy.HeartbeatLogsOrderBy) }


{-| An edge for our `HeartbeatLog`. May be used by Relay 1.

  - orderBy - The method to use when ordering `HeartbeatLog`.

-}
heartbeatLogEdge : (HeartbeatLogEdgeOptionalArguments -> HeartbeatLogEdgeOptionalArguments) -> SelectionSet decodesTo Beatmon.Api.Object.HeartbeatLogsEdge -> Field (Maybe decodesTo) Beatmon.Api.Object.CreateHeartbeatLogPayload
heartbeatLogEdge fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { orderBy = Absent }

        optionalArgs =
            [ Argument.optional "orderBy" filledInOptionals.orderBy (Encode.enum Beatmon.Api.Enum.HeartbeatLogsOrderBy.toString |> Encode.list) ]
                |> List.filterMap identity
    in
    Object.selectionField "heartbeatLogEdge" optionalArgs object_ (identity >> Decode.nullable)

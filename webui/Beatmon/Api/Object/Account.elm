-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Beatmon.Api.Object.Account exposing (HeartbeatsByAccountIdOptionalArguments, accountId, email, heartbeatsByAccountId, isActive, isAdmin, nodeId, selection)

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
selection : (a -> constructor) -> SelectionSet (a -> constructor) Beatmon.Api.Object.Account
selection constructor =
    Object.selection constructor


{-| A globally unique identifier. Can be used in various places throughout the system to identify this single value.
-}
nodeId : Field Beatmon.Api.Scalar.Id Beatmon.Api.Object.Account
nodeId =
    Object.fieldDecoder "nodeId" [] (Object.scalarDecoder |> Decode.map Beatmon.Api.Scalar.Id)


accountId : Field Beatmon.Api.Scalar.BigInt Beatmon.Api.Object.Account
accountId =
    Object.fieldDecoder "accountId" [] (Object.scalarDecoder |> Decode.map Beatmon.Api.Scalar.BigInt)


email : Field String Beatmon.Api.Object.Account
email =
    Object.fieldDecoder "email" [] Decode.string


isAdmin : Field Bool Beatmon.Api.Object.Account
isAdmin =
    Object.fieldDecoder "isAdmin" [] Decode.bool


isActive : Field Bool Beatmon.Api.Object.Account
isActive =
    Object.fieldDecoder "isActive" [] Decode.bool


type alias HeartbeatsByAccountIdOptionalArguments =
    { first : OptionalArgument Int, last : OptionalArgument Int, offset : OptionalArgument Int, before : OptionalArgument Beatmon.Api.Scalar.Cursor, after : OptionalArgument Beatmon.Api.Scalar.Cursor, orderBy : OptionalArgument (List Beatmon.Api.Enum.HeartbeatsOrderBy.HeartbeatsOrderBy), condition : OptionalArgument Beatmon.Api.InputObject.HeartbeatCondition }


{-| Reads and enables pagination through a set of `Heartbeat`.

  - first - Only read the first `n` values of the set.
  - last - Only read the last `n` values of the set.
  - offset - Skip the first `n` values from our `after` cursor, an alternative to cursor based pagination. May not be used with `last`.
  - before - Read all values in the set before (above) this cursor.
  - after - Read all values in the set after (below) this cursor.
  - orderBy - The method to use when ordering `Heartbeat`.
  - condition - A condition to be used in determining which values should be returned by the collection.

-}
heartbeatsByAccountId : (HeartbeatsByAccountIdOptionalArguments -> HeartbeatsByAccountIdOptionalArguments) -> SelectionSet decodesTo Beatmon.Api.Object.HeartbeatsConnection -> Field decodesTo Beatmon.Api.Object.Account
heartbeatsByAccountId fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { first = Absent, last = Absent, offset = Absent, before = Absent, after = Absent, orderBy = Absent, condition = Absent }

        optionalArgs =
            [ Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "last" filledInOptionals.last Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int, Argument.optional "before" filledInOptionals.before (\(Beatmon.Api.Scalar.Cursor raw) -> Encode.string raw), Argument.optional "after" filledInOptionals.after (\(Beatmon.Api.Scalar.Cursor raw) -> Encode.string raw), Argument.optional "orderBy" filledInOptionals.orderBy (Encode.enum Beatmon.Api.Enum.HeartbeatsOrderBy.toString |> Encode.list), Argument.optional "condition" filledInOptionals.condition Beatmon.Api.InputObject.encodeHeartbeatCondition ]
                |> List.filterMap identity
    in
    Object.selectionField "heartbeatsByAccountId" optionalArgs object_ identity

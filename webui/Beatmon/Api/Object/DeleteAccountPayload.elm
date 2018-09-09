-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Beatmon.Api.Object.DeleteAccountPayload exposing (AccountEdgeOptionalArguments, account, accountEdge, clientMutationId, deletedAccountId, query, selection)

import Beatmon.Api.Enum.AccountsOrderBy
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
selection : (a -> constructor) -> SelectionSet (a -> constructor) Beatmon.Api.Object.DeleteAccountPayload
selection constructor =
    Object.selection constructor


{-| The exact same `clientMutationId` that was provided in the mutation input, unchanged and unused. May be used by a client to track mutations.
-}
clientMutationId : Field (Maybe String) Beatmon.Api.Object.DeleteAccountPayload
clientMutationId =
    Object.fieldDecoder "clientMutationId" [] (Decode.string |> Decode.nullable)


{-| The `Account` that was deleted by this mutation.
-}
account : SelectionSet decodesTo Beatmon.Api.Object.Account -> Field (Maybe decodesTo) Beatmon.Api.Object.DeleteAccountPayload
account object_ =
    Object.selectionField "account" [] object_ (identity >> Decode.nullable)


deletedAccountId : Field (Maybe Beatmon.Api.Scalar.Id) Beatmon.Api.Object.DeleteAccountPayload
deletedAccountId =
    Object.fieldDecoder "deletedAccountId" [] (Object.scalarDecoder |> Decode.map Beatmon.Api.Scalar.Id |> Decode.nullable)


{-| Our root query field type. Allows us to run any query from our mutation payload.
-}
query : SelectionSet decodesTo RootQuery -> Field (Maybe decodesTo) Beatmon.Api.Object.DeleteAccountPayload
query object_ =
    Object.selectionField "query" [] object_ (identity >> Decode.nullable)


type alias AccountEdgeOptionalArguments =
    { orderBy : OptionalArgument (List Beatmon.Api.Enum.AccountsOrderBy.AccountsOrderBy) }


{-| An edge for our `Account`. May be used by Relay 1.

  - orderBy - The method to use when ordering `Account`.

-}
accountEdge : (AccountEdgeOptionalArguments -> AccountEdgeOptionalArguments) -> SelectionSet decodesTo Beatmon.Api.Object.AccountsEdge -> Field (Maybe decodesTo) Beatmon.Api.Object.DeleteAccountPayload
accountEdge fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { orderBy = Absent }

        optionalArgs =
            [ Argument.optional "orderBy" filledInOptionals.orderBy (Encode.enum Beatmon.Api.Enum.AccountsOrderBy.toString |> Encode.list) ]
                |> List.filterMap identity
    in
    Object.selectionField "accountEdge" optionalArgs object_ (identity >> Decode.nullable)
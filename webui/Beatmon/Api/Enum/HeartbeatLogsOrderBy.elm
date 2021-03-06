-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Beatmon.Api.Enum.HeartbeatLogsOrderBy exposing (HeartbeatLogsOrderBy(..), decoder, toString)

import Json.Decode as Decode exposing (Decoder)


{-| Methods to use when ordering `HeartbeatLog`.
-}
type HeartbeatLogsOrderBy
    = Natural
    | DateAsc
    | DateDesc
    | HeartbeatIdAsc
    | HeartbeatIdDesc
    | AccountIdAsc
    | AccountIdDesc
    | PrimaryKeyAsc
    | PrimaryKeyDesc


decoder : Decoder HeartbeatLogsOrderBy
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "NATURAL" ->
                        Decode.succeed Natural

                    "DATE_ASC" ->
                        Decode.succeed DateAsc

                    "DATE_DESC" ->
                        Decode.succeed DateDesc

                    "HEARTBEAT_ID_ASC" ->
                        Decode.succeed HeartbeatIdAsc

                    "HEARTBEAT_ID_DESC" ->
                        Decode.succeed HeartbeatIdDesc

                    "ACCOUNT_ID_ASC" ->
                        Decode.succeed AccountIdAsc

                    "ACCOUNT_ID_DESC" ->
                        Decode.succeed AccountIdDesc

                    "PRIMARY_KEY_ASC" ->
                        Decode.succeed PrimaryKeyAsc

                    "PRIMARY_KEY_DESC" ->
                        Decode.succeed PrimaryKeyDesc

                    _ ->
                        Decode.fail ("Invalid HeartbeatLogsOrderBy type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representating the Enum to a string that the GraphQL server will recognize.
-}
toString : HeartbeatLogsOrderBy -> String
toString enum =
    case enum of
        Natural ->
            "NATURAL"

        DateAsc ->
            "DATE_ASC"

        DateDesc ->
            "DATE_DESC"

        HeartbeatIdAsc ->
            "HEARTBEAT_ID_ASC"

        HeartbeatIdDesc ->
            "HEARTBEAT_ID_DESC"

        AccountIdAsc ->
            "ACCOUNT_ID_ASC"

        AccountIdDesc ->
            "ACCOUNT_ID_DESC"

        PrimaryKeyAsc ->
            "PRIMARY_KEY_ASC"

        PrimaryKeyDesc ->
            "PRIMARY_KEY_DESC"

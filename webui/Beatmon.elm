module Beatmon exposing
    ( Context
    , Cursor
    , Heartbeat
    , Page
    , apiContext
    , getHeartbeats
    , login
    , loginWithToken
    )

import Beatmon.Api.Mutation as Mutation
import Beatmon.Api.Object as Api
import Beatmon.Api.Object.Account as Account
import Beatmon.Api.Object.AuthenticatePayload
import Beatmon.Api.Object.Heartbeat as Heartbeat
import Beatmon.Api.Object.HeartbeatsConnection as HeartbeatsConnection
import Beatmon.Api.Object.PageInfo as PageInfo
import Beatmon.Api.Query as Query
import Beatmon.Api.Scalar as Api
import Beatmon.Page exposing (Cursor, Page, fromApiCursor, toApiCursor)
import Graphql.Field as Field
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument as OptionalArgument exposing (OptionalArgument)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Maybe.Extra as Maybe
import RemoteData exposing (RemoteData(..))
import Task exposing (Task)
import Utils.Maybe as Maybe


type alias Page a =
    Beatmon.Page.Cursor a


type alias Cursor a =
    Beatmon.Page.Cursor a


type alias Context =
    { url : String
    , token : Maybe String
    }


type alias Account =
    { id : Int
    , email : String
    }


type alias Heartbeat =
    { id : String
    , name : Maybe String
    , notifyAfter : Int
    }


type alias LoginError =
    String


login : Context -> { username : String, password : String } -> Task LoginError Context
login ctx credentials =
    loginQuery credentials.username credentials.password
        |> sendMutation ctx
        |> handleErrors "Wrong username or password"
        |> Task.map (setToken ctx)


loginWithToken : Context -> String -> Task String Context
loginWithToken baseCtx rawToken =
    let
        ctx =
            setToken baseCtx (Api.JwtToken rawToken)
    in
    currentAccountQuery
        |> sendQuery ctx
        |> Task.map (Debug.log "Ok")
        |> Task.mapError (Debug.log "Err")
        |> handleErrors "Not logged in"
        |> Task.map (\_ -> ctx)


getHeartbeats : Context -> Maybe (Cursor Heartbeat) -> Task String (Page Heartbeat)
getHeartbeats ctx cursor =
    heartbeatsQuery cursor
        |> sendQuery ctx
        |> handleErrors "Failed to retrieve heartbeats"


apiContext : String -> Context
apiContext url =
    { url = url, token = Nothing }


setToken : Context -> Api.JwtToken -> Context
setToken ctx (Api.JwtToken t) =
    { ctx | token = Just t }


sendMutation :
    Context
    -> SelectionSet a RootMutation
    -> Task (Graphql.Http.Error a) a
sendMutation { url, token } mutation =
    Graphql.Http.mutationRequest url mutation
        |> Maybe.apply token
            (\t -> Graphql.Http.withHeader "Authorization" ("Bearer " ++ t))
        |> Graphql.Http.toTask


sendQuery : Context -> SelectionSet a RootQuery -> Task (Graphql.Http.Error a) a
sendQuery { url, token } query =
    Graphql.Http.queryRequest url query
        |> Maybe.apply token
            (\t -> Graphql.Http.withHeader "Authorization" ("Bearer " ++ t))
        |> Graphql.Http.toTask


handleErrors : String -> Task (Graphql.Http.Error (Maybe a)) (Maybe a) -> Task String a
handleErrors onNothing =
    Task.mapError (Debug.log "API Error")
        >> Task.mapError
            (\_ -> "There was a problem when communicating with the server")
        >> Task.andThen
            (Maybe.map Task.succeed >> Maybe.withDefault (Task.fail onNothing))


loginQuery : String -> String -> SelectionSet (Maybe Api.JwtToken) RootMutation
loginQuery username password =
    Mutation.selection Maybe.join
        |> with
            (Mutation.authenticate
                { input =
                    { clientMutationId = OptionalArgument.Absent
                    , email = username
                    , password = password
                    }
                }
                (Beatmon.Api.Object.AuthenticatePayload.selection (\a -> a)
                    |> with Beatmon.Api.Object.AuthenticatePayload.jwtToken
                )
            )


currentAccountQuery : SelectionSet (Maybe Account) RootQuery
currentAccountQuery =
    Query.selection identity
        |> with
            (Query.currentAccount
                (Account.selection Account
                    |> with (Account.accountId |> Field.map fromApiBigInt |> Field.nonNullOrFail)
                    |> with Account.email
                )
            )


fromApiBigInt : Api.BigInt -> Maybe Int
fromApiBigInt (Api.BigInt i) =
    String.toInt i


heartbeatsQuery : Maybe (Cursor Heartbeat) -> SelectionSet (Maybe (Page Heartbeat)) RootQuery
heartbeatsQuery cursor =
    Query.selection identity
        |> with
            (Query.allHeartbeats
                (\a -> { a | after = cursor |> Maybe.map toApiCursor |> argOrAbsent })
                (HeartbeatsConnection.selection (\f n -> f n)
                    |> with (HeartbeatsConnection.pageInfo infoForPage)
                    |> with (HeartbeatsConnection.nodes heartbeatSelector |> Field.nonNullElementsOrFail)
                )
            )


heartbeatSelector : SelectionSet Heartbeat Api.Heartbeat
heartbeatSelector =
    Heartbeat.selection Heartbeat
        |> with (Field.map unUUID Heartbeat.heartbeatId)
        |> with Heartbeat.name
        |> with Heartbeat.notifyAfterSeconds


unUUID : Api.Uuid -> String
unUUID (Api.Uuid s) =
    s


argOrAbsent : Maybe a -> OptionalArgument a
argOrAbsent =
    Maybe.map OptionalArgument.Present
        >> Maybe.withDefault OptionalArgument.Absent


infoForPage : SelectionSet (List a -> Page a) Api.PageInfo
infoForPage =
    let
        buildPage hasNextPage endCursor nodes =
            { endCursor = maybeIf endCursor hasNextPage |> Maybe.map fromApiCursor
            , nodes = nodes
            }
    in
    PageInfo.selection buildPage
        |> with PageInfo.hasNextPage
        |> with PageInfo.endCursor


maybeIf : Maybe a -> Bool -> Maybe a
maybeIf aMaybe bool =
    if bool then
        aMaybe

    else
        Nothing

module Beatmon exposing (Context, apiContext, login)

import Beatmon.Api.Mutation as Mutation
import Beatmon.Api.Object.AuthenticatePayload
import Beatmon.Api.Query as Query
import Beatmon.Api.Scalar as Api
import Graphql.Field as Field
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument as OptionalArgument exposing (OptionalArgument)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Maybe.Extra as Maybe
import RemoteData exposing (RemoteData(..))
import Task exposing (Task)


type Context
    = Context RawContext


type alias RawContext =
    { url : String
    , token : Maybe String
    }


type alias LoginError =
    String


login : Context -> { username : String, password : String } -> Task LoginError Context
login ctx credentials =
    loginQuery credentials.username credentials.password
        |> sendMutation ctx
        |> Task.mapError (\_ -> "There was a problem when communicating with the server")
        |> Task.andThen
            (Maybe.map (setToken ctx >> Task.succeed)
                >> Maybe.withDefault (Task.fail "Wrong username or password")
            )


apiContext : String -> Context
apiContext url =
    Context { url = url, token = Nothing }


setToken : Context -> Api.JwtToken -> Context
setToken (Context ctx) (Api.JwtToken t) =
    Context { ctx | token = Just t }


sendMutation :
    Context
    -> SelectionSet a RootMutation
    -> Task (Graphql.Http.Error a) a
sendMutation (Context ctx) mutation =
    Graphql.Http.mutationRequest ctx.url mutation
        |> applyMaybe ctx.token
            (\t -> Graphql.Http.withHeader "Authorization" ("Bearer " ++ t))
        |> Graphql.Http.toTask


applyMaybe : Maybe a -> (a -> b -> b) -> b -> b
applyMaybe m f =
    Maybe.map f m |> Maybe.withDefault identity


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

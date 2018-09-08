module Main exposing (Model, main)

import Beatmon.Api.Mutation as Mutation
import Beatmon.Api.Object.AuthenticatePayload
import Beatmon.Api.Query as Query
import Beatmon.Api.Scalar as Beatmon
import Browser
import Debug
import Graphql.Field as Field
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument as OptionalArgument exposing (OptionalArgument)
import Graphql.SelectionSet exposing (SelectionSet, with)
import Html exposing (Html)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onSubmit)
import Maybe.Extra as Maybe
import RemoteData exposing (RemoteData(..))


type alias Model =
    { view : View
    }


type Msg
    = LoginMsg LoginMsg
    | LoggedIn String


type LoginMsg
    = SetUsername String
    | SetPassword String
    | Login
    | LoginFailed String


type View
    = LoginView LoginViewVM
    | SuccessView
        { jwtToken : String
        }


type alias LoginViewVM =
    { username : String
    , password : String
    , error : Maybe String
    }


init () =
    ( { view =
            LoginView
                { username = ""
                , password = ""
                , error = Nothing
                }
      }
    , Cmd.none
    )


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.view ) of
        ( LoginMsg m, LoginView vm ) ->
            let
                ( vm_, cmd ) =
                    updateLoginView m vm
            in
            ( { model | view = LoginView vm_ }, cmd )

        ( LoginMsg _, _ ) ->
            ( model, Cmd.none )

        ( LoggedIn token, _ ) ->
            ( { model | view = SuccessView { jwtToken = token } }, Cmd.none )


updateLoginView : LoginMsg -> LoginViewVM -> ( LoginViewVM, Cmd Msg )
updateLoginView msg vm =
    case msg of
        SetUsername u ->
            ( { vm | username = u }
            , Cmd.none
            )

        SetPassword p ->
            ( { vm | password = p }
            , Cmd.none
            )

        Login ->
            ( vm
            , loginQuery vm.username vm.password
                |> sendBeatmonMutation handleLoginResponse
            )

        LoginFailed e ->
            ( { vm | error = Just e }
            , Cmd.none
            )


sendBeatmonMutation :
    (RemoteData (Graphql.Http.Error a) a -> msg)
    -> SelectionSet a RootMutation
    -> Cmd msg
sendBeatmonMutation msg mutation =
    Graphql.Http.mutationRequest "http://localhost:5000/graphql" mutation
        |> Graphql.Http.send (RemoteData.fromResult >> msg)


handleLoginResponse : RemoteData e (Maybe LoginResponse) -> Msg
handleLoginResponse r =
    case r of
        RemoteData.NotAsked ->
            Debug.todo "NotAsked"

        RemoteData.Loading ->
            Debug.todo "Loading"

        RemoteData.Success mR ->
            case mR of
                Nothing ->
                    LoginFailed "Wrong username or password" |> LoginMsg

                Just { jwtToken } ->
                    LoggedIn jwtToken

        RemoteData.Failure e ->
            LoginFailed (Debug.toString e) |> LoginMsg


view : Model -> Browser.Document Msg
view model =
    case model.view of
        LoginView viewState ->
            { title = "Log in"
            , body =
                [ loginForm viewState
                ]
            }

        SuccessView { jwtToken } ->
            { title = "Yo", body = [ Html.text jwtToken ] }


type alias LoginResponse =
    { jwtToken : String }


unJwtToken : Beatmon.JwtToken -> String
unJwtToken (Beatmon.JwtToken t) =
    t


loginQuery : String -> String -> SelectionSet (Maybe LoginResponse) RootMutation
loginQuery username password =
    Mutation.selection (Maybe.map (unJwtToken >> LoginResponse))
        |> with
            (Mutation.authenticate
                { input =
                    { clientMutationId = OptionalArgument.Absent
                    , email = username
                    , password = password
                    }
                }
                (Beatmon.Api.Object.AuthenticatePayload.selection (\a -> a)
                    |> with (Field.nonNullOrFail Beatmon.Api.Object.AuthenticatePayload.jwtToken)
                )
            )


loginForm : { username : String, password : String, error : Maybe String } -> Html Msg
loginForm { username, password, error } =
    Html.form [ onSubmit (Login |> LoginMsg) ]
        ([ Html.input [ value username, onInput (SetUsername >> LoginMsg) ] []
         , Html.input [ value password, onInput (SetPassword >> LoginMsg), type_ "password" ] []
         , Html.button [] [ Html.text "Login" ]
         ]
            ++ (error
                    |> Maybe.map (Html.text >> List.singleton >> Html.div [])
                    |> Maybe.toList
               )
        )

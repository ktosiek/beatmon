module Main exposing (main)

import Beatmon
import Browser
import Browser.Dom
import Debug
import Html exposing (Html)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onSubmit)
import Maybe.Extra as Maybe
import RemoteData exposing (RemoteData(..))
import Task
import Utils.Result as Result


type alias Model =
    { view : View
    , apiContext : Beatmon.Context
    }


type Msg
    = LoginMsg LoginMsg
    | LoggedIn Beatmon.Context


type LoginMsg
    = SetUsername String
    | SetPassword String
    | Login
    | LoginFailed String


type View
    = LoginView LoginViewVM
    | SuccessView


type alias LoginViewVM =
    { username : String
    , password : String
    , error : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { view =
            LoginView
                { username = ""
                , password = ""
                , error = Nothing
                }
      , apiContext = Beatmon.apiContext "http://localhost:5000/graphql"
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
                    updateLoginView model m vm
            in
            ( { model | view = LoginView vm_ }, cmd )

        ( LoginMsg _, _ ) ->
            ( model, Cmd.none )

        ( LoggedIn ctx, _ ) ->
            ( { model | view = SuccessView, apiContext = ctx }, Cmd.none )


updateLoginView : Model -> LoginMsg -> LoginViewVM -> ( LoginViewVM, Cmd Msg )
updateLoginView model msg vm =
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
            , Beatmon.login model.apiContext
                { username = vm.username
                , password = vm.password
                }
                |> Task.attempt
                    (Result.map LoggedIn
                        >> Result.mapError (LoginFailed >> LoginMsg)
                        >> Result.merge
                    )
            )

        LoginFailed e ->
            ( { vm | error = Just e }
            , Cmd.none
            )


view : Model -> Browser.Document Msg
view model =
    case model.view of
        LoginView viewState ->
            { title = "Log in"
            , body =
                [ loginForm viewState
                ]
            }

        SuccessView ->
            { title = "Yo", body = [ Html.text (Debug.toString model.apiContext) ] }


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

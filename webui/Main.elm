module Main exposing (main)

import Beatmon
import Bootstrap
import Browser
import Debug
import Html exposing (Html)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onSubmit)
import Maybe.Extra as Maybe
import Model exposing (..)
import Pages.Heartbeats.Model as Heartbeats
import Pages.Heartbeats.View as Heartbeats
import Pages.Login.Model as Login
import Pages.Login.View as Login
import Ports
import RemoteData exposing (RemoteData(..))
import Return
import Task
import Utils.Maybe as Maybe
import Utils.Result as Result


type alias Flags =
    { apiToken : Maybe String
    }


init : Bootstrap.BootstrapFlags -> Flags -> ( Model, Cmd Msg )
init boot flags =
    { view = LoadingView
    , apiContext = Beatmon.apiContext "http://localhost:5000/graphql"
    , timeZone = boot.timeZone
    }
        |> Return.singleton
        |> (case flags.apiToken of
                Just apiToken ->
                    Return.effect_ (tryToken apiToken)

                Nothing ->
                    initView LoginView Login.init
           )


main =
    Bootstrap.document
        { init = init
        , view = view
        , loadingView = loading
        , update = update
        , subscriptions = \_ -> Sub.none
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( Debug.log "msg" msg, model.view ) of
        ( LoginMsg m, LoginView vm ) ->
            let
                ( vm_, cmd ) =
                    Login.update model m vm
            in
            ( { model | view = LoginView vm_ }, cmd )

        ( LoginMsg _, _ ) ->
            ( model, Cmd.none )

        ( HeartbeatsMsg m, HeartbeatsView vm ) ->
            Heartbeats.update model m vm
                |> Return.map (\vm_ -> { model | view = HeartbeatsView vm_ })

        ( HeartbeatsMsg _, _ ) ->
            ( model, Cmd.none )

        ( LoggedIn ctx, _ ) ->
            { model | apiContext = ctx }
                |> Return.singleton
                |> initView HeartbeatsView Heartbeats.init
                |> Return.effect_ saveApiToken

        ( ShowLogin, _ ) ->
            Return.singleton model
                |> initView LoginView Login.init

        ( LogOut, _ ) ->
            { model | apiContext = Beatmon.resetApiToken model.apiContext }
                |> Return.singleton
                |> initView LoginView Login.init
                |> Return.effect_ saveApiToken

        ( NoOp, _ ) ->
            ( model, Cmd.none )


initView : (vm -> View) -> (Model -> ( vm, Cmd Msg )) -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initView viewName viewInit ( model, baseCmd ) =
    let
        ( vm, viewCmd ) =
            viewInit model
    in
    ( { model | view = viewName vm }, Cmd.batch [ baseCmd, viewCmd ] )


saveApiToken : Model -> Cmd Msg
saveApiToken model =
    Ports.saveApiToken model.apiContext.token


tryToken : String -> Model -> Cmd Msg
tryToken token { apiContext } =
    Beatmon.loginWithToken apiContext token
        |> Task.attempt
            (Result.map LoggedIn
                >> Result.mapError (\_ -> ShowLogin)
                >> Result.merge
            )


view : Model -> Browser.Document Msg
view model =
    case model.view of
        LoadingView ->
            loading

        LoginView viewState ->
            Login.view viewState

        HeartbeatsView vm ->
            Heartbeats.view model vm


loading =
    { title = "", body = [ Html.text "Loading..." ] }

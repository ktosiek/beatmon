module Main exposing (main)

import Beatmon
import Browser
import Debug
import Html exposing (Html)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onSubmit)
import Maybe.Extra as Maybe
import Model exposing (..)
import Pages.Login.Model as Login
import Pages.Login.View as Login
import RemoteData exposing (RemoteData(..))
import Task
import Utils.Result as Result


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
                    Login.update model m vm
            in
            ( { model | view = LoginView vm_ }, cmd )

        ( LoginMsg _, _ ) ->
            ( model, Cmd.none )

        ( LoggedIn ctx, _ ) ->
            ( { model | view = SuccessView, apiContext = ctx }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    case model.view of
        LoginView viewState ->
            Login.view viewState

        SuccessView ->
            { title = "Yo", body = [ Html.text (Debug.toString model.apiContext) ] }

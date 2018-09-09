module Pages.Login.View exposing (init, update, view)

import Beatmon
import Browser
import Html exposing (Html)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onSubmit)
import Maybe.Extra as Maybe
import Model exposing (..)
import Pages.Login.Model as Login exposing (Context, Msg(..))
import Task
import Utils.Result as Result


init : Login.Model
init =
    { username = ""
    , password = ""
    , error = Nothing
    }


update : Context a -> Login.Msg -> Login.Model -> ( Login.Model, Cmd Model.Msg )
update { apiContext } msg vm =
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
            , Beatmon.login apiContext
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


view : Login.Model -> Browser.Document Model.Msg
view vm =
    { title = "Log in"
    , body = [ loginForm vm |> Html.map LoginMsg ]
    }


loginForm : Login.Model -> Html Msg
loginForm { username, password, error } =
    Html.form [ onSubmit Login ]
        ([ Html.input [ value username, onInput SetUsername ] []
         , Html.input [ value password, onInput SetPassword, type_ "password" ] []
         , Html.button [] [ Html.text "Login" ]
         ]
            ++ (error
                    |> Maybe.map (Html.text >> List.singleton >> Html.div [])
                    |> Maybe.toList
               )
        )

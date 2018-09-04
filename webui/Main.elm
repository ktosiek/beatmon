module Main exposing (Model, main)

import Browser
import Html exposing (Html)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onSubmit)


type alias Model =
    { view : View
    }


type Msg
    = LoginMsg LoginMsg


type LoginMsg
    = SetUsername String
    | SetPassword String
    | Login


type View
    = LoginView { username : String, password : String }


init () =
    ( { view =
            LoginView
                { username = ""
                , password = ""
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
        ( LoginMsg (SetUsername u), LoginView vm ) ->
            ( { model | view = LoginView { vm | username = u } }
            , Cmd.none
            )

        ( LoginMsg (SetPassword p), LoginView vm ) ->
            ( { model | view = LoginView { vm | password = p } }
            , Cmd.none
            )

        ( LoginMsg Login, LoginView vm ) ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    case model.view of
        LoginView viewState ->
            { title = "Log in"
            , body =
                [ loginForm viewState
                ]
            }


loginForm : { username : String, password : String } -> Html Msg
loginForm { username, password } =
    Html.form [ onSubmit (Login |> LoginMsg) ]
        [ Html.input [ value username, onInput (SetUsername >> LoginMsg) ] []
        , Html.input [ value password, onInput (SetPassword >> LoginMsg), type_ "password" ] []
        , Html.button [] [ Html.text "Login" ]
        ]

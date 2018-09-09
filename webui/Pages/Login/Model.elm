module Pages.Login.Model exposing (Context, Model, Msg(..))

import Beatmon


type Msg
    = SetUsername String
    | SetPassword String
    | Login
    | LoginFailed String


type alias Model =
    { username : String
    , password : String
    , error : Maybe String
    }


type alias Context a =
    { a | apiContext : Beatmon.Context }

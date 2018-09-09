module Model exposing (Model, Msg(..), View(..))

import Beatmon
import Pages.Login.Model as Login


type alias Model =
    { view : View
    , apiContext : Beatmon.Context
    }


type Msg
    = LoginMsg Login.Msg
    | LoggedIn Beatmon.Context


type View
    = LoginView Login.Model
    | SuccessView

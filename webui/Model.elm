module Model exposing (Model, Msg(..), View(..))

import Beatmon
import Pages.Heartbeats.Model as Heartbeats
import Pages.Login.Model as Login


type alias Model =
    { view : View
    , apiContext : Beatmon.Context
    }


type Msg
    = LoginMsg Login.Msg
    | HeartbeatsMsg Heartbeats.Msg
    | LoggedIn Beatmon.Context
    | ShowLogin
    | NoOp


type View
    = LoginView Login.Model
    | HeartbeatsView Heartbeats.Model
    | LoadingView

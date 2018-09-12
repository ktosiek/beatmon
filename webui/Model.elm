module Model exposing (Model, Msg(..), View(..))

import Beatmon
import Pages.Heartbeats.Model as Heartbeats
import Pages.Login.Model as Login
import Time


type alias Model =
    { view : View
    , apiContext : Beatmon.Context
    , timeZone : Time.Zone
    }


type Msg
    = LoginMsg Login.Msg
    | HeartbeatsMsg Heartbeats.Msg
    | LoggedIn Beatmon.Context
    | ShowLogin
    | LogOut
    | NoOp


type View
    = LoginView Login.Model
    | HeartbeatsView Heartbeats.Model
    | LoadingView

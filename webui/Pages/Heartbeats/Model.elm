module Pages.Heartbeats.Model exposing (Context, Model, Msg(..))

import Beatmon
import RemoteData exposing (RemoteData)


type Msg
    = HeartbeatsLoaded (RemoteData String (Beatmon.Page Beatmon.Heartbeat))


type alias Model =
    { heartbeats : RemoteData String (Beatmon.Page Beatmon.Heartbeat)
    }


type alias Context a =
    { a
        | apiContext : Beatmon.Context
    }

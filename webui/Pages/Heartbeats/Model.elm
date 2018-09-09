module Pages.Heartbeats.Model exposing (Context, Model, Msg(..))

import Beatmon
import Beatmon.Page exposing (Page)
import RemoteData exposing (RemoteData)


type Msg
    = HeartbeatsLoaded (RemoteData String (Page Beatmon.Heartbeat))


type alias Model =
    { heartbeats : RemoteData String (Page Beatmon.Heartbeat)
    }


type alias Context a =
    { a
        | apiContext : Beatmon.Context
    }

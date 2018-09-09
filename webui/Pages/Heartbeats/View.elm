module Pages.Heartbeats.View exposing (init, update, view)

import Beatmon exposing (Heartbeat)
import Beatmon.Page as Page exposing (Page)
import Browser
import Html exposing (Html)
import Model
import Pages.Heartbeats.Model exposing (..)
import RemoteData exposing (RemoteData(..))
import Time
import Utils.List as List
import Utils.Time as Time


init : Context a -> ( Model, Cmd Model.Msg )
init { apiContext } =
    ( { heartbeats = RemoteData.Loading }
    , Beatmon.getHeartbeats apiContext Nothing
        |> RemoteData.asCmd
        |> Cmd.map (HeartbeatsLoaded >> Model.HeartbeatsMsg)
    )


update : Context a -> Msg -> Model -> ( Model, Cmd Model.Msg )
update { apiContext } msg vm =
    case msg of
        HeartbeatsLoaded r ->
            ( { vm | heartbeats = r }, Cmd.none )


view : Context a -> Model -> Browser.Document Model.Msg
view ctx vm =
    { title = "Heartbeats"
    , body = [ heartbeatsPage ctx vm |> Html.map Model.HeartbeatsMsg ]
    }


heartbeatsPage : Context a -> Model -> Html Msg
heartbeatsPage ctx { heartbeats } =
    case heartbeats of
        NotAsked ->
            Debug.todo "NotAsked"

        Loading ->
            Html.text "Loading..."

        Failure e ->
            Html.text e

        Success h ->
            heartbeatsTable ctx h


heartbeatsTable : Context a -> Page Heartbeat -> Html Msg
heartbeatsTable ctx heartbeatPage =
    Html.div [] <|
        [ Html.table [] (List.map (heartbeatRow ctx) heartbeatPage.nodes)
        ]
            ++ List.ifTrue (Page.hasNext heartbeatPage) (Html.text "...and more!")


heartbeatRow : Context a -> Heartbeat -> Html Msg
heartbeatRow { timeZone } { id, name, notifyAfter, lastSeen } =
    Html.tr []
        [ Html.td [] [ id |> Html.text ]
        , Html.td [] [ name |> Maybe.withDefault "" |> Html.text ]
        , Html.td [] [ humaneDuration notifyAfter |> Html.text ]
        , Html.td [] [ lastSeen |> Maybe.map (humaneTimestamp timeZone) |> Maybe.withDefault "Never" |> Html.text ]
        ]


humaneDuration : Int -> String
humaneDuration allSeconds =
    let
        ( minutes, seconds ) =
            divMod allSeconds 60
    in
    String.fromInt minutes ++ ":" ++ String.fromInt seconds


humaneTimestamp : Time.Zone -> Time.Posix -> String
humaneTimestamp tz t =
    let
        s f =
            f tz t |> String.fromInt |> String.padLeft 2 '0'
    in
    String.join ""
        [ s Time.toYear, "-", s Time.toMonthNumber, "-", s Time.toDay, " ", s Time.toHour, ":", s Time.toMinute, ":", s Time.toSecond ]


divMod : Int -> Int -> ( Int, Int )
divMod a b =
    ( a // b, modBy a b )

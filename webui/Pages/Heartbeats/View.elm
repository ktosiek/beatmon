module Pages.Heartbeats.View exposing (init, update, view)

import Beatmon exposing (Heartbeat)
import Beatmon.Page as Page exposing (Page)
import Browser
import Html exposing (Html)
import Model
import Pages.Heartbeats.Model exposing (..)
import RemoteData exposing (RemoteData(..))
import Utils.List as List


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


view : Model -> Browser.Document Model.Msg
view vm =
    { title = "Heartbeats"
    , body = [ heartbeatsPage vm |> Html.map Model.HeartbeatsMsg ]
    }


heartbeatsPage : Model -> Html Msg
heartbeatsPage { heartbeats } =
    case heartbeats of
        NotAsked ->
            Debug.todo "NotAsked"

        Loading ->
            Html.text "Loading..."

        Failure e ->
            Html.text e

        Success h ->
            heartbeatsTable h


heartbeatsTable : Page Heartbeat -> Html Msg
heartbeatsTable heartbeatPage =
    Html.div [] <|
        [ Html.table [] (List.map heartbeatRow heartbeatPage.nodes)
        ]
            ++ List.ifTrue (Page.hasNext heartbeatPage) (Html.text "...and more!")


heartbeatRow : Heartbeat -> Html Msg
heartbeatRow { id, name, notifyAfter } =
    Html.tr []
        [ Html.td [] [ id |> Html.text ]
        , Html.td [] [ name |> Maybe.withDefault "" |> Html.text ]
        , Html.td [] [ humaneDuration notifyAfter |> Html.text ]
        ]


humaneDuration : Int -> String
humaneDuration allSeconds =
    let
        ( minutes, seconds ) =
            divMod allSeconds 60
    in
    String.fromInt minutes ++ ":" ++ String.fromInt seconds


divMod : Int -> Int -> ( Int, Int )
divMod a b =
    ( a // b, modBy a b )

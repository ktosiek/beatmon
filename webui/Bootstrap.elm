module Bootstrap exposing (BootstrapFlags, document)

import Browser exposing (Document)
import Return
import Task
import Time
import Utils.Browser.Document as Document


type Model m f
    = Bootstrap { flags : f, timeZone : Maybe Time.Zone }
    | Done m


type Msg m
    = GotTimeZone Time.Zone
    | Internal m


type alias BootstrapFlags =
    { timeZone : Time.Zone
    }


document :
    { init : BootstrapFlags -> flags -> ( model, Cmd msg )
    , view : model -> Document msg
    , loadingView : Document msg
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    }
    -> Program flags (Model model flags) (Msg msg)
document { init, view, loadingView, update, subscriptions } =
    Browser.document
        { init = bootInit
        , view = bootView view loadingView
        , update = bootUpdate update init
        , subscriptions = bootSubscriptions subscriptions
        }


bootInit : flags -> ( Model m flags, Cmd (Msg msg) )
bootInit flags =
    ( Bootstrap
        { flags = flags
        , timeZone = Nothing
        }
    , Time.here |> Task.perform GotTimeZone
    )


bootView : (m -> Document msg) -> Document msg -> Model m f -> Document (Msg msg)
bootView view loading bootModel =
    Document.map Internal <|
        case bootModel of
            Bootstrap _ ->
                loading

            Done m ->
                view m


bootUpdate :
    (msg -> m -> ( m, Cmd msg ))
    -> (BootstrapFlags -> flags -> ( m, Cmd msg ))
    -> Msg msg
    -> Model m flags
    -> ( Model m flags, Cmd (Msg msg) )
bootUpdate update init msg bootModel =
    case ( msg, bootModel ) of
        ( GotTimeZone tz, Bootstrap m ) ->
            { m | timeZone = Just tz }
                |> finalizeBoot init

        ( Internal msg_, Done m ) ->
            update msg_ m
                |> Return.map Done
                |> Return.mapCmd Internal

        ( Internal _, Bootstrap _ ) ->
            ( bootModel, Cmd.none )

        ( _, Done _ ) ->
            ( bootModel, Cmd.none )


bootSubscriptions subscriptions model =
    case model of
        Bootstrap m ->
            Sub.none

        Done m ->
            subscriptions m |> Sub.map Internal


finalizeBoot :
    (BootstrapFlags -> f -> ( m, Cmd msg ))
    -> { flags : f, timeZone : Maybe Time.Zone }
    -> ( Model m f, Cmd (Msg msg) )
finalizeBoot init { flags, timeZone } =
    case timeZone of
        Just tz ->
            init { timeZone = tz } flags
                |> Return.map Done
                |> Return.mapCmd Internal

        Nothing ->
            ( Bootstrap { flags = flags, timeZone = Nothing }, Cmd.none )

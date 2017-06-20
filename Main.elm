module Main exposing (..)

import Html exposing (..)
import Keyboard exposing (KeyCode, ups)


type Msg
    = KeyPress KeyCode


type alias Step =
    Int


type alias Model =
    { step : Step }


navigate : Step -> KeyCode -> Int
navigate step code =
    case code of
        39 ->
            step + 1

        37 ->
            clamp 0 step (step - 1)

        _ ->
            step



-- model


init : ( Model, Cmd Msg )
init =
    ( { step = 0 }, Cmd.none )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPress code ->
            ( { model | step = navigate model.step code }, Cmd.none )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    ups KeyPress



-- view


view : Model -> Html Msg
view model =
    div
        []
        [ h1
            []
            [ text ("Step " ++ (toString model.step)) ]
        ]


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

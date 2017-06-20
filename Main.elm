module Main exposing (..)

import Html exposing (..)


type Msg
    = MoveForwards
    | MoveBackwards



-- model


type alias Model =
    { slide : Int }


init : ( Model, Cmd Msg )
init =
    ( { slide = 0 }, Cmd.none )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MoveForwards ->
            ( { model | slide = model.slide + 1 }, Cmd.none )

        MoveBackwards ->
            ( { model | slide = model.slide - 1 }, Cmd.none )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- view


view : Model -> Html Msg
view model =
    div
        []
        [ h1
            []
            [ text ("Slide " ++ (toString model.slide)) ]
        ]


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

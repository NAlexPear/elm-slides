module Main exposing (..)

import Navigators
    exposing
        ( getDeckId
        , getQueryParams
        , getRoute
        )
import Ports
    exposing
        ( getToken
        , newToken
        )
import Requests
    exposing
        ( getDeck
        , getDecks
        , saveDeck
        )
import Array
import Array exposing (Array)
import Decoders exposing (decodeLogin)
import Keyboard exposing (ups)
import Message exposing (Msg(..))
import Navigation
import Types exposing (..)
import Update exposing (update)
import View exposing (view)
import UrlParser as Url


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init { token } location =
    let
        slides =
            { previous = []
            , current = { content = "" }
            , remaining = []
            }

        sidebar =
            if .edit <| getQueryParams location then
                Inactive
            else
                Disabled

        user =
            case token of
                Just validToken ->
                    Authorized <| AuthUser 1 "test" validToken
                _ ->
                    Anonymous
    in
        ( { decks =
                { current =
                    { title = ""
                    , id = 1
                    , slides = slides
                    }
                , others = Array.empty
                }
          , sidebar = sidebar
          , history = [ location ]
          , swipe = { clientX = 0, clientY = 0 }
          , user = user
          }
        , case getRoute location of
            Just Verify ->
                getToken "Getting the hash!"

            Just (Presentation _ _) ->
                location
                    |> getDeckId
                    |> getDeck

            _ ->
                Cmd.none
        )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ ups KeyPress
        , newToken <| decodeLogin >> Login
        ]


main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

module Main exposing (..)

import Navigators
    exposing
        ( getDeckTitle
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


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
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
          , user = Anonymous
          }
        , case getRoute location of
            Just Verify ->
                getToken "Getting the hash!"

            Just (Presentation _ _) ->
                location
                    |> getDeckTitle
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


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

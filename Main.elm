module Main exposing (..)

import Debug
import Array
import Array exposing (Array)
import Keyboard exposing (ups)
import Message exposing (Msg(..))
import Navigation
import Navigators exposing (getDeckTitle, getQueryParams)
import Requests exposing (getDeck, getDecks, saveDeck)
import Types exposing (..)
import Update exposing (update)
import View exposing (view)


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        slides =
            { previous = []
            , current = { content = "" }
            , remaining = []
            }

        sidebar =
            if Debug.log "editing?" (.edit <| getQueryParams location) then
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
        , location
            |> getDeckTitle
            |> getDeck
        )


subscriptions : Model -> Sub Msg
subscriptions _ =
    ups KeyPress


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

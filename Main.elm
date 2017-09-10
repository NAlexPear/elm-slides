module Main exposing (..)

import Array
import Array exposing (Array)
import Keyboard exposing (ups)
import Message exposing (Msg(..))
import Navigation
import Navigators exposing (getDeckTitle, route)
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
    in
        ( { decks =
                { current =
                    { title = ""
                    , id = 1
                    , slides = slides
                    }
                , others = Array.empty
                }
          , sidebar = Inactive
          , history = [ location ]
          , swipe = { clientX = 0, clientY = 0 }
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

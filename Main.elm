module Main exposing (..)

import Array
import Array exposing (Array)
import Components exposing (icons, slide)
import Html exposing (..)
import Html.Attributes exposing (..)
import Keyboard exposing (ups)
import Message exposing (Msg(..))
import Navigation
import Navigators exposing (getDeckTitle, route)
import Requests exposing (getDeck, getDecks, saveDeck)
import Types exposing (..)
import Update exposing (update)


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
          }
        , location
            |> getDeckTitle
            |> getDeck
        )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    ups KeyPress



-- view


view : Model -> Html Msg
view ({ decks, sidebar } as model) =
    let
        renderer =
            slide model

        iconClasses =
            if sidebar == ChangingDeck || sidebar == EditingDeck then
                "active"
            else
                ""

        sidebarView =
            model
                |> icons
                |> div [ id "icons", class iconClasses ]
                |> List.singleton

        slides =
            decks.current.slides
    in
        div
            []
            [ node "link" [ rel "stylesheet", href "//cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" ] []
            , slides.remaining
                |> List.append [ slides.current ]
                |> List.append slides.previous
                |> List.foldl renderer []
                |> List.append sidebarView
                |> div [ id "container" ]
            ]


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

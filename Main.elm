module Main exposing (..)

import Array
import Array exposing (Array)
import Components exposing (icons, slide)
import Html exposing (..)
import Html.Attributes exposing (..)
import Keyboard exposing (ups)
import Message exposing (Msg(..))
import Requests exposing (getDeck, getDecks, saveDeck)
import Types exposing (..)
import Update exposing (update)


init : ( Model, Cmd Msg )
init =
    ( { step = 0
      , decks =
            { current =
                { title = ""
                , id = 1
                , slides = Array.empty
                }
            , others = Array.empty
            }
      , sidebar = Inactive
      }
    , getDeck 1
    )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    ups KeyPress



-- view


view : Model -> Html Msg
view model =
    let
        renderer =
            slide model

        sidebar =
            model.sidebar

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
    in
        div
            []
            [ node "link" [ rel "stylesheet", href "//cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" ] []
            , node "link" [ rel "stylesheet", href "main.css" ] []
            , model.decks.current.slides
                |> Array.foldl renderer []
                |> List.append sidebarView
                |> div [ id "container" ]
            ]


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

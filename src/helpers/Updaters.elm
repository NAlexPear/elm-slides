module Updaters exposing (addSlide)

import Types exposing (..)


getInjectedSlides : Slides -> Slides
getInjectedSlides ({ previous, current } as slides) =
    { slides
        | previous = previous ++ [ current ]
        , current =
            { content = "# This is a new slide \n ...and add some content!"
            , id = List.length previous
            }
    }


addSlide : Model -> Model
addSlide ({ decks } as model) =
    let
        deck =
            decks.current

        newDeck =
            { deck | slides = getInjectedSlides deck.slides }

        newDecks =
            { decks | current = newDeck }
    in
        { model
            | decks = newDecks
            , sidebar = EditingSlide
        }

module Updaters exposing (addSlide, deleteSlide, updateSlide, updateCurrentDeck, updateOtherDecks)

import Array
import Array exposing (Array)
import Message exposing (Msg)
import Requests exposing (saveDeck)
import Types exposing (..)


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


deleteSlide : Decks -> Cmd Msg
deleteSlide { current } =
    let
        remaining =
            current.slides.previous ++ current.slides.remaining

        newCurrent =
            case List.head remaining of
                Just newCurrent ->
                    newCurrent

                Nothing ->
                    { content = "# There are no more slides in this deck! \n Edit this slide to start again"
                    , id = 1
                    }

        newRemaining =
            case List.tail remaining of
                Just newRemaining ->
                    newRemaining

                Nothing ->
                    []

        slides =
            { previous = []
            , current = newCurrent
            , remaining = newRemaining
            }

        newDeck =
            { current | slides = slides }
    in
        saveDeck newDeck


updateSlide : Model -> String -> Model
updateSlide ({ decks } as model) newContent =
    let
        current =
            decks.current

        slides =
            current.slides

        slide =
            slides.current

        newSlide =
            { slide | content = newContent }

        newSlides =
            { slides | current = newSlide }

        newDeck =
            { current | slides = newSlides }

        newDecks =
            { decks | current = newDeck }
    in
        { model | decks = newDecks }


getInjectedSlides : Slides -> Slides
getInjectedSlides ({ previous, current } as slides) =
    { slides
        | previous = previous ++ [ current ]
        , current =
            { content = "# This is a new slide \n ...and add some content!"
            , id = List.length previous
            }
    }


updateCurrentDeck : Model -> Deck -> Model
updateCurrentDeck ({ decks } as model) newCurrentDeck =
    let
        newDecks =
            { decks | current = newCurrentDeck }
    in
        { model | decks = newDecks }


updateOtherDecks : Model -> Array Deck -> Model
updateOtherDecks ({ decks } as model) newOtherDecks =
    let
        filteredDecks =
            Array.filter (\{ id } -> id /= decks.current.id) newOtherDecks

        newDecks =
            { decks | others = filteredDecks }
    in
        { model | decks = newDecks }

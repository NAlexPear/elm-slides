module Updaters exposing (updateTitle, updateSlides, addSlide)

import Array
import Types exposing (..)


mapIdToIndex : Int -> Slide -> Slide
mapIdToIndex index slide =
    { slide | id = index + 1 }


updateTitle : Deck -> String -> Deck
updateTitle deck newTitle =
    { deck | title = newTitle }


updateSlides : Model -> String -> Deck
updateSlides model newContent =
    let
        id =
            model.step + 1

        deck =
            model.decks.current

        slide =
            { content = newContent
            , id = id
            }

        slides =
            Array.set model.step slide deck.slides
    in
        { deck | slides = slides }


addSlide : Model -> Model
addSlide model =
    let
        slide =
            { content = "# This is a new slide \n ...and add some content!"
            , id = model.step
            }

        length =
            Array.length model.decks.current.slides

        head =
            model.decks.current.slides
                |> Array.slice 0 model.step
                |> Array.push slide

        tail =
            model.decks.current.slides
                |> Array.slice model.step length

        slides =
            tail
                |> Array.append head
                |> Array.indexedMap mapIdToIndex

        decks =
            model.decks

        deck =
            decks.current

        newDeck =
            { deck | slides = slides }

        newDecks =
            { decks | current = deck }
    in
        { model
            | decks = newDecks
            , isEditing = True
            , isChangingDeck = False
        }

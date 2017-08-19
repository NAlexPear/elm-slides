module Initiators exposing (initiateSlideSave, initiateSlideDelete)

import Array
import Message exposing (Msg)
import Types exposing (..)
import Requests exposing (saveDeck)


rejectSlideById : Int -> Slide -> Bool
rejectSlideById id slide =
    slide.id /= id


mapIdToIndex : Int -> Slide -> Slide
mapIdToIndex index slide =
    { slide | id = index + 1 }


initiateSlideSave : Model -> Cmd Msg
initiateSlideSave model =
    saveDeck model.decks.current


initiateSlideDelete : Model -> Cmd Msg
initiateSlideDelete model =
    let
        deck =
            model.decks.current

        remaining =
            deck.slides.previous ++ deck.slides.remaining

        slides =
            { previous = []
            , current = List.head remaining
            , remaining = List.tail remaining
            }

        newDeck =
            { deck | slides = slides }
    in
        saveDeck deck

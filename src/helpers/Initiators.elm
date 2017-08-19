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
        id =
            model.step + 1

        predicate =
            rejectSlideById id

        deck =
            model.decks.current

        slides =
            model.decks.current.slides
                |> Array.filter predicate
                |> Array.indexedMap mapIdToIndex

        newDeck =
            { deck | slides = slides }
    in
        saveDeck deck

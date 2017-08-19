module Navigators exposing (navigate)

import Types exposing (..)
import Keyboard exposing (KeyCode)
import Array


stepForwards : Decks -> Decks
stepForwards ({ current } as decks) =
    let
        slides =
            current.slides

        newCurrent =
            case List.head slides.remaining of
                Just newCurrent ->
                    newCurrent

                Nothing ->
                    slides.current

        newSlides =
            if List.isEmpty slides.remaining then
                slides
            else
                { previous = slides.previous ++ [ slides.current ]
                , current = newCurrent
                , remaining = List.drop 1 slides.remaining
                }

        newDeck =
            { current | slides = newSlides }
    in
        { decks | current = newDeck }


stepBackwards : Decks -> Decks
stepBackwards ({ current } as decks) =
    let
        slides =
            current.slides

        penultimate =
            List.length slides.previous - 1

        newCurrent =
            case slides.previous |> List.reverse |> List.head of
                Just newCurrent ->
                    newCurrent

                Nothing ->
                    slides.current

        newSlides =
            if List.isEmpty slides.previous then
                slides
            else
                { previous = List.take penultimate slides.previous
                , current = newCurrent
                , remaining = slides.current :: slides.remaining
                }

        newDeck =
            { current | slides = newSlides }
    in
        { decks | current = newDeck }


navigate : Model -> KeyCode -> Decks
navigate { decks, sidebar } code =
    let
        slides =
            decks.current.slides
    in
        if sidebar == EditingSlide then
            decks
        else
            case code of
                39 ->
                    stepForwards decks

                37 ->
                    stepBackwards decks

                _ ->
                    decks

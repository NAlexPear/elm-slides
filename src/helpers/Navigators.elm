module Navigators exposing (navigate, route, getDeckId)

import Array
import Keyboard exposing (KeyCode)
import Navigation
import Types exposing (..)
import UrlParser as Url exposing ((</>))


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map Presentation <| Url.s "decks" </> Url.int ]


getDeckId : Navigation.Location -> Int
getDeckId location =
    case Url.parsePath route location of
        Just (Presentation id) ->
            id

        Nothing ->
            1


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

module Updaters
    exposing
        ( addSlide
        , changeDeck
        , deleteSlide
        , handleEditHotkey
        , mapKeyToMsg
        , moveToFirstDeck
        , updateSlide
        , updateCurrentDeck
        , updateOtherDecks
        )

import Array
import Array exposing (Array)
import Message exposing (Msg)
import Navigation exposing (newUrl)
import Regex exposing (Regex, regex, replace)
import Requests exposing (saveDeck)
import Types exposing (..)


mapKeyToMsg : Model -> Int -> Cmd Msg
mapKeyToMsg { decks, sidebar } code =
    if code == 27 && sidebar == EditingSlide then
        saveDeck decks.current
    else
        Cmd.none


handleEditHotkey : Sidebar -> Int -> Sidebar
handleEditHotkey sidebar code =
    if code == 69 && sidebar /= EditingDeck then
        EditingSlide
    else
        sidebar


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
                    { content = "# There are no more slides in this deck! \n Edit this slide to start again" }

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


changeDeck : String -> Cmd Msg
changeDeck title =
    title
        |> String.toLower
        |> replace (Regex.All) (regex " ") (\_ -> "-")
        |> (++) "/decks/"
        |> flip (++) "?edit=true"
        |> newUrl


moveToFirstDeck : Decks -> Cmd Msg
moveToFirstDeck { others } =
    let
        last =
            Array.get 0 others
    in
        case last of
            Just { title } ->
                changeDeck title

            Nothing ->
                Cmd.none

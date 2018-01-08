module Navigators
    exposing
        ( getDeckTitle
        , getQueryParams
        , getRoute
        , navigate
        )

import Regex
    exposing
        ( Regex
        , regex
        , replace
        )
import UrlParser as Url
    exposing
        ( (</>)
        , (<?>)
        )
import Keyboard exposing (KeyCode)
import Navigation exposing (Location)
import Types exposing (..)


unhyphenate : String -> String
unhyphenate string =
    replace (Regex.All) (regex "-") (\_ -> " ") string


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map Presentation <| Url.s "decks" </> Url.string <?> Url.stringParam "edit"
        , Url.map Verify <| Url.s "verify"
        ]


getQueryParams : Location -> Params
getQueryParams location =
    case Url.parsePath route location of
        Just (Presentation _ (Just "true")) ->
            { edit = True }

        _ ->
            { edit = False }


getDeckTitle : Location -> String
getDeckTitle location =
    case Url.parsePath route location of
        Just (Presentation title _) ->
            unhyphenate title

        _ ->
            ""


getRoute : Location -> Maybe Route
getRoute location =
    Url.parsePath route location


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
            case slides.remaining of
                [] ->
                    slides

                _ ->
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
            case slides.previous of
                [] ->
                    slides

                _ ->
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
    case sidebar of
        EditingSlide ->
            decks

        _ ->
            case code of
                39 ->
                    stepForwards decks

                37 ->
                    stepBackwards decks

                _ ->
                    decks

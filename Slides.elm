module Slides exposing (Slide, getSlides, getDecks)

import Message exposing (Msg(..))
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Http


type alias Slide =
    { title : String, content : String }


type alias Deck =
    { title : String, id : Int }


slideDecoder : Decoder Slide
slideDecoder =
    decode Slide
        |> required "title" string
        |> required "content" string


slidesDecoder : Decoder (List Slide)
slidesDecoder =
    list slideDecoder


deckDecoder : Decoder Deck
deckDecoder =
    decode Deck
        |> required "title" string
        |> required "id" int


decksDecoder : Decoder (List Deck)
decksDecoder =
    list deckDecoder



-- saveSlides : List Slide -> Int -> Cmd Msg
-- saveSlides newSlides deck =
--     let
--         url =
--             "http://localhost:3000/decks/" ++ toString deck
--
--         request =
--             Http.post url newSlides slidesDecoder
--     in
--         Http.send SaveSlides request


getDecks : Cmd Msg
getDecks =
    let
        url =
            "http://localhost:3000/decks"

        request =
            Http.get url decksDecoder
    in
        Http.send GetDecks request


getSlides : Int -> Cmd Msg
getSlides deck =
    let
        slides =
            at [ "slides" ] slidesDecoder

        url =
            "http://localhost:3000/decks/" ++ toString deck

        request =
            Http.get url slides
    in
        Http.send GetSlides request

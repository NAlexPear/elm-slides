module Requests exposing (getDeck, getDecks, saveDeck)

import Message exposing (Msg(..))
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode
import Types exposing (..)
import Array exposing (Array)
import Array
import Http


patch : String -> Http.Body -> Decoder a -> Http.Request a
patch url body decoder =
    Http.request
        { method = "PATCH"
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


slideDecoder : Decoder Slide
slideDecoder =
    decode Slide
        |> required "content" string
        |> required "id" int


slideEncoder : Slide -> Encode.Value
slideEncoder slide =
    Encode.object
        [ ( "content", Encode.string slide.content )
        , ( "id", Encode.int slide.id )
        ]


slidesDecoder : Decoder Slides
slidesDecoder =
    array slideDecoder


slidesEncoder : Array Slide -> Encode.Value
slidesEncoder slides =
    let
        slidesList =
            slides
                |> Array.map slideEncoder
                |> Encode.array
    in
        Encode.object [ ( "slides", slidesList ) ]


deckDecoder : Decoder Deck
deckDecoder =
    decode Deck
        |> required "title" string
        |> required "id" int
        |> required "slides" slidesDecoder


decksDecoder : Decoder (Array Deck)
decksDecoder =
    array deckDecoder


deckEncoder : Deck -> Encode.Value
deckEncoder deck =
    Encode.object [ ( "title", Encode.string deck.title ) ]


saveDeck : Deck -> Cmd Msg
saveDeck deck =
    let
        url =
            "http://localhost:3000/decks/" ++ toString deck.id

        body =
            deck
                |> deckEncoder
                |> Http.jsonBody

        request =
            patch url body deckDecoder
    in
        Http.send SaveDeck request


getDecks : Cmd Msg
getDecks =
    let
        url =
            "http://localhost:3000/decks"

        request =
            Http.get url decksDecoder
    in
        Http.send GetDecks request


getDeck : Int -> Cmd Msg
getDeck deck =
    let
        url =
            "http://localhost:3000/decks/" ++ toString deck

        request =
            Http.get url deckDecoder
    in
        Http.send GetDeck request

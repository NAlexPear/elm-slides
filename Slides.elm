module Slides exposing (getSlides, saveSlides, getDecks)

import Message exposing (Msg(..))
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode
import Types exposing (..)
import Array exposing (Array)
import Array
import Http


patch : String -> Http.Body -> Decoder Slides -> Http.Request Slides
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


decksDecoder : Decoder Decks
decksDecoder =
    list deckDecoder


saveSlides : Slides -> Int -> Cmd Msg
saveSlides newSlides deck =
    let
        url =
            "http://localhost:3000/decks/" ++ toString deck

        body =
            newSlides
                |> slidesEncoder
                |> Http.jsonBody

        responseDecoder =
            at [ "slides" ] slidesDecoder

        request =
            patch url body responseDecoder
    in
        Http.send SaveSlides request


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

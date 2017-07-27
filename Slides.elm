module Slides exposing (Slide, getSlides, saveSlides, getDecks)

import Message exposing (Msg(..))
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode
import Http


type alias Slide =
    { title : String, content : String, id : Int }


type alias Deck =
    { title : String, id : Int }


patch : String -> Http.Body -> Decoder (List Slide) -> Http.Request (List Slide)
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
        |> required "title" string
        |> required "content" string
        |> required "id" int


slideEncoder : Slide -> Encode.Value
slideEncoder slide =
    Encode.object
        [ ( "title", Encode.string slide.title )
        , ( "content", Encode.string slide.content )
        , ( "id", Encode.int slide.id )
        ]


slidesDecoder : Decoder (List Slide)
slidesDecoder =
    list slideDecoder


slidesEncoder : List Slide -> Encode.Value
slidesEncoder slides =
    let
        slidesList =
            slides
                |> List.map slideEncoder
                |> Encode.list
    in
        Encode.object [ ( "slides", slidesList ) ]


deckDecoder : Decoder Deck
deckDecoder =
    decode Deck
        |> required "title" string
        |> required "id" int


decksDecoder : Decoder (List Deck)
decksDecoder =
    list deckDecoder


saveSlides : List Slide -> Int -> Cmd Msg
saveSlides newSlides deck =
    let
        url =
            "http://localhost:3000/decks/" ++ toString deck

        body =
            newSlides
                |> slidesEncoder
                |> Http.jsonBody

        request =
            patch url body slidesDecoder
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

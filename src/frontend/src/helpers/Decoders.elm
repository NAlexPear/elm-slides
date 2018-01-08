module Decoders
    exposing
        ( decodeDeck
        , decodeDecks
        , decodeLogin
        )

import Array exposing (Array)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Types exposing (..)


decodeDeck : Decoder Deck
decodeDeck =
    decode Deck
        |> required "title" string
        |> required "id" int
        |> required "slides" decodeSlides


decodeDecks : Decoder (Array Deck)
decodeDecks =
    array decodeDeck


decodeLogin : Value -> Result String AuthPayload
decodeLogin =
    decode AuthPayload
        |> required "previousDeck" string
        |> required "token" string
        |> decodeValue


decodeSlide : Decoder Slide
decodeSlide =
    decode Slide
        |> required "content" string


decodeSlides : Decoder Slides
decodeSlides =
    let
        slides =
            list decodeSlide
    in
        map mapSlides slides


mapSlides : List Slide -> Slides
mapSlides slidesList =
    let
        slides =
            { previous = []
            , current = Slide ""
            , remaining = []
            }
    in
        case slidesList of
            x :: y ->
                { slides
                    | current = x
                    , remaining = y
                }

            _ ->
                slides

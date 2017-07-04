module Slides exposing (Slide, getSlides)

import Message exposing (Msg(..))
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Http


type alias Slide =
    { title : String, content : String }


slideDecoder : Decoder Slide
slideDecoder =
    decode Slide
        |> required "title" string
        |> required "content" string


slidesDecoder : Decoder (List Slide)
slidesDecoder =
    list slideDecoder


getSlides : Cmd Msg
getSlides =
    let
        slides =
            at [ "slides" ] slidesDecoder

        request =
            Http.get "http://localhost:3000/decks/1" slides
    in
        Http.send NewSlides request

module Encoders exposing (encodeDeck)

import Json.Encode as Encode
import Types exposing (..)


encodeDeck : Deck -> Encode.Value
encodeDeck { id, slides, title } =
    Encode.object
        [ ( "title", Encode.string title )
        , ( "slides", encodeSlides (slides.previous ++ [ slides.current ] ++ slides.remaining) )
        , ( "id", Encode.int id)
        ]


encodeSlide : Slide -> Encode.Value
encodeSlide slide =
    Encode.object
        [ ( "content", Encode.string slide.content ) ]


encodeSlides : List Slide -> Encode.Value
encodeSlides slides =
    slides
        |> List.map encodeSlide
        |> Encode.list

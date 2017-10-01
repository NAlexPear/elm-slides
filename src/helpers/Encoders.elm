module Encoders exposing (encodeDeck)

import Json.Encode as Encode
import Types exposing (..)


encodeDeck : Deck -> Encode.Value
encodeDeck { slides, title } =
    Encode.object
        [ ( "title", Encode.string title )
        , ( "slides", encodeSlides (slides.previous ++ [ slides.current ] ++ slides.remaining) )
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

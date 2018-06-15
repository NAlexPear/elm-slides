module Encoders
    exposing
        ( encodeDeck
        , encodeSlides
        )

import Json.Encode as Encode
import Types exposing (..)

type alias DeckSlide =
    { content: String
    , deck_id: Int
    }
encodeDeck : Deck -> Encode.Value
encodeDeck { id, slides, title } =
    Encode.object
        [ ( "title", Encode.string title )
        , ( "id", Encode.int id)
        ]


encodeSlide : DeckSlide -> Encode.Value
encodeSlide slide =
    Encode.object
        [ ( "content", Encode.string slide.content )
        , ( "deck_id", Encode.int slide.deck_id )
        ]


encodeSlides : List DeckSlide -> Encode.Value
encodeSlides slides =
    slides
        |> List.map encodeSlide
        |> Encode.list

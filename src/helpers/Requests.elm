module Requests exposing (createDeck, getDeck, getDecks, saveDeck)

import Array
import Array exposing (Array)
import Http
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode
import Message exposing (Msg(..))
import Types exposing (..)


patch : String -> Http.Body -> Http.Request String
patch url body =
    Http.request
        { method = "PATCH"
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }


slideDecoder : Decoder Slide
slideDecoder =
    decode Slide
        |> required "content" string


slideEncoder : Slide -> Encode.Value
slideEncoder slide =
    Encode.object
        [ ( "content", Encode.string slide.content ) ]


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


slidesDecoder : Decoder Slides
slidesDecoder =
    let
        slides =
            list slideDecoder
    in
        map mapSlides slides


slidesEncoder : List Slide -> Encode.Value
slidesEncoder slides =
    slides
        |> List.map slideEncoder
        |> Encode.list


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
deckEncoder { slides, title } =
    Encode.object
        [ ( "title", Encode.string title )
        , ( "slides", slidesEncoder (slides.previous ++ [ slides.current ] ++ slides.remaining) )
        ]


createDeck : Cmd Msg
createDeck =
    let
        url =
            "/api/decks/"

        deck =
            { slides =
                { previous = []
                , current = { content = "# New Slide" }
                , remaining = []
                }
            , title = "New Deck"
            , id = 0 -- placeholder id
            }

        body =
            deck
                |> deckEncoder
                |> Http.jsonBody

        request =
            Http.post url body <| succeed "Deck created!"
    in
        Http.send SaveDeck request


saveDeck : Deck -> Cmd Msg
saveDeck deck =
    let
        url =
            deck.id
                |> toString
                |> (++) "/api/decks/"

        body =
            deck
                |> deckEncoder
                |> Http.jsonBody

        request =
            patch url body
    in
        Http.send SaveDeck request


getDecks : Cmd Msg
getDecks =
    let
        request =
            Http.get "/api/decks" decksDecoder
    in
        Http.send GetDecks request


getDeck : Int -> Cmd Msg
getDeck deck =
    let
        url =
            deck
                |> toString
                |> (++) "/api/decks/"

        request =
            Http.get url deckDecoder
    in
        Http.send GetDeck request

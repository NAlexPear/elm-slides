module Requests exposing (createDeck, deleteDeck, getDeck, getDecks, saveDeck)

import Array
import Array exposing (Array)
import Http
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode
import Message exposing (Msg(..))
import Regex exposing (Regex, regex, replace)
import Types exposing (..)


getSingle : String -> Decoder a -> Http.Request a
getSingle url decoder =
    Http.request
        { method = "GET"
        , headers = [ (Http.header "Accept" "application/vnd.pgrst.object+json") ]
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


insert : String -> Http.Body -> String -> Http.Request String
insert url body method =
    Http.request
        { method = method
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }


patch : String -> Http.Body -> Http.Request String
patch url body =
    insert url body "PATCH"


post : String -> Http.Body -> Http.Request String
post url body =
    insert url body "POST"


delete : String -> Http.Request String
delete url =
    insert url Http.emptyBody "DELETE"


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
            "/api/decks"

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
            post url body
    in
        Http.send SaveDeck request


deleteDeck : Deck -> Cmd Msg
deleteDeck deck =
    let
        url =
            deck.title
                |> String.toLower
                |> replace (Regex.All) (regex " ") (\_ -> "-")
                |> (++) "/api/decks?title=ilike."

        request =
            delete url
    in
        Http.send DeleteDeck request


saveDeck : Deck -> Cmd Msg
saveDeck deck =
    let
        url =
            deck.title
                |> String.toLower
                |> replace (Regex.All) (regex " ") (\_ -> "-")
                |> (++) "/api/decks?title=ilike."

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


getDeck : String -> Cmd Msg
getDeck title =
    let
        url =
            title
                |> (++) "/api/decks?title=ilike."

        request =
            getSingle url deckDecoder
    in
        Http.send GetDeck request

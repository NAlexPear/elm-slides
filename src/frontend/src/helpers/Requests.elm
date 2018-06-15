module Requests
    exposing
        ( createDeck
        , deleteDeck
        , getDeck
        , getDecks
        , saveDeck
        , saveSlides
        )

import Decoders
    exposing
        ( decodeDeck
        , decodeDecks
        )

import Encoders
    exposing
        ( encodeDeck
        , encodeSlides
        )

import Array
import Array exposing (Array)
import Http
import Json.Decode exposing (Decoder)
import Message exposing (Msg(..))
import Types exposing (..)


getSingle : String -> Decoder a -> Http.Request a
getSingle url decoder =
    Http.request
        { method = "GET"
        , headers = [ (Http.header "Accept" "application/json") ]
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
                |> encodeDeck
                |> Http.jsonBody

        request =
            post url body
    in
        Http.send SaveDeck request


deleteDeck : Deck -> Cmd Msg
deleteDeck deck =
    let
        url =
            deck.id
                |> toString
                |> (++) "/api/decks/"

        request =
            delete url
    in
        Http.send DeleteDeck request


saveDeck : Deck -> Cmd Msg
saveDeck deck =
    let
        url =
            deck.id
                |> toString
                |> (++) "/api/decks/"

        body =
            deck
                |> encodeDeck
                |> Http.jsonBody

        request =
            patch url body
    in
        Http.send SaveDeck request

saveSlides : Deck -> Cmd Msg
saveSlides deck =
    let
        id =
            toString deck.id

        url =
            "/api/decks/" ++ id ++ "/slides"

        body =
            deck.slides.remaining
                |> (++) [ deck.slides.current ]
                |> (++) deck.slides.previous
                |> List.map ( \x -> { content = x.content, deck_id = deck.id } )
                |> encodeSlides
                |> Http.jsonBody

        request =
            patch url body
    in
        Http.send SaveSlides request

getDecks : Cmd Msg
getDecks =
    let
        request =
            Http.get "/api/decks" decodeDecks
    in
        Http.send GetDecks request


getDeck : Int -> Cmd Msg
getDeck id =
    let
        url =
            "/api/decks/" ++ toString id

        request =
            getSingle url decodeDeck
    in
        Http.send GetDeck request

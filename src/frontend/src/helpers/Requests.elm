module Requests
    exposing
        ( createDeck
        , deleteDeck
        , getDeck
        , getDecks
        , saveDeck
        )

import Decoders
    exposing
        ( decodeDeck
        , decodeDecks
        )
import Array
import Array exposing (Array)
import Encoders exposing (encodeDeck)
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
            deck.title
                |> String.toLower
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
                |> (++) "/api/decks?title=ilike."

        body =
            deck
                |> encodeDeck
                |> Http.jsonBody

        request =
            patch url body
    in
        Http.send SaveDeck request


getDecks : Cmd Msg
getDecks =
    let
        request =
            Http.get "/api/decks" decodeDecks
    in
        Http.send GetDecks request


getDeck : String -> Cmd Msg
getDeck title =
    let
        url =
            "/api/decks?title=ilike." ++ title

        request =
            getSingle url decodeDeck
    in
        Http.send GetDeck request

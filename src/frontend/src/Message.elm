module Message exposing (Msg(..))

import Array exposing (Array)
import Http
import Json.Decode exposing (Value)
import Keyboard exposing (KeyCode)
import Navigation exposing (Location)
import Touch
import Types exposing (..)


type Msg
    = KeyPress KeyCode
    | GetDeck (Result Http.Error Deck)
    | SaveDeck (Result Http.Error String)
    | GetDecks (Result Http.Error (Array Deck))
    | DeleteDeck (Result Http.Error String)
    | QueueSave
    | QueueSlideDelete
    | QueueDeckDelete
    | AddSlide
    | CreateDeck
    | ChangeDeck Int
    | SwipeStart Touch.Coordinates
    | SwipeEnd Touch.Coordinates
    | ToggleChangeDeck
    | ToggleEditDeck
    | ToggleEdit
    | UpdateSlide String
    | UpdateDeckTitle String
    | UrlChange Location
    | Authenticate
    | Login (Result String AuthPayload)
    | Logout
    | NoOp

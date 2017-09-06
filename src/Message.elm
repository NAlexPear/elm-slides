module Message exposing (Msg(..))

import Array exposing (Array)
import Http
import Keyboard exposing (KeyCode)
import Navigation exposing (Location)
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
    | ToggleChangeDeck
    | ToggleEditDeck
    | ToggleEdit
    | UpdateSlide String
    | UpdateDeckTitle String
    | UrlChange Location
    | NoOp

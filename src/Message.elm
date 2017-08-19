module Message exposing (Msg(..))

import Keyboard exposing (KeyCode)
import Types exposing (..)
import Http


type Msg
    = KeyPress KeyCode
    | GetDeck (Result Http.Error Deck)
    | SaveDeck (Result Http.Error Deck)
    | GetDecks (Result Http.Error Decks)
    | QueueSave
    | QueueDelete
    | QueueSaveDeck
    | AddSlide
    | ChangeDeck Int
    | ToggleChangeDeck
    | ToggleEditDeck
    | ToggleEdit
    | UpdateContent String
    | UpdateTitle String
    | NoOp

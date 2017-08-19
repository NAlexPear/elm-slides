module Message exposing (Msg(..))

import Array exposing (Array)
import Keyboard exposing (KeyCode)
import Types exposing (..)
import Http


type Msg
    = KeyPress KeyCode
    | GetDeck (Result Http.Error Deck)
    | SaveDeck (Result Http.Error Deck)
    | GetDecks (Result Http.Error (Array Deck))
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

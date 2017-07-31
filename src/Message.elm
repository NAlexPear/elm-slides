module Message exposing (Msg(..))

import Keyboard exposing (KeyCode)
import Types exposing (..)
import Http


type Msg
    = KeyPress KeyCode
    | GetSlides (Result Http.Error Slides)
    | SaveSlides (Result Http.Error Slides)
    | GetDecks (Result Http.Error Decks)
    | SaveDeck (Result Http.Error Deck)
    | QueueSave
    | QueueDelete
    | QueueSaveDeck
    | AddSlide
    | ChangeDeck Int
    | ToggleChangeDeck
    | ToggleEditDeck
    | ToggleEdit
    | UpdateContent String
    | NoOp

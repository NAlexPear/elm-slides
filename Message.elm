module Message exposing (Msg(..))

import Keyboard exposing (KeyCode)
import Types exposing (..)
import Http


type Msg
    = KeyPress KeyCode
    | GetSlides (Result Http.Error Slides)
    | GetDecks (Result Http.Error Decks)
    | SaveSlides (Result Http.Error Slides)
    | QueueSave
    | AddSlide
    | ToggleChangeDeck
    | ToggleEdit
    | UpdateContent String

module Message exposing (Msg(..))

import Keyboard exposing (KeyCode)
import Http


type alias Slide =
    { title : String, content : String }


type alias Deck =
    { title : String, id : Int }


type alias Slides =
    List Slide


type alias Decks =
    List Deck


type Msg
    = KeyPress KeyCode
    | GetSlides (Result Http.Error Slides)
    | GetDecks (Result Http.Error Decks)
    | SaveSlides (Result Http.Error Slides)
    | AddSlide
    | ToggleChangeDeck
    | ToggleEdit

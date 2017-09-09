module Types exposing (..)

import Array exposing (Array)
import Navigation exposing (Location)


type alias Slide =
    { content : String }


type alias Slides =
    { previous : List Slide
    , current : Slide
    , remaining : List Slide
    }


type alias Deck =
    { title : String
    , id : Int
    , slides : Slides
    }


type alias Decks =
    { current : Deck
    , others : Array Deck
    }


type alias History =
    List Location


type Route
    = Presentation String


type Sidebar
    = EditingSlide
    | ChangingDeck
    | EditingDeck
    | Inactive


type alias Model =
    { decks : Decks
    , sidebar : Sidebar
    , history : History
    }

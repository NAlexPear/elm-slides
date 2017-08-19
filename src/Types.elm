module Types exposing (..)

import Array exposing (Array)


type alias Slide =
    { content : String
    , id : Int
    }


type alias Slides =
    Array Slide


type alias Deck =
    { title : String
    , id : Int
    , slides : Slides
    }


type alias Decks =
    { current : Deck
    , others : Array Deck
    }


type Sidebar
    = EditingSlide
    | ChangingDeck
    | EditingDeck
    | Inactive


type alias Model =
    { step : Int
    , decks : Decks
    , sidebar : Sidebar
    }

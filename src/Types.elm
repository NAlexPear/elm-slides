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


type alias Sidebar =
    { isEditing : Bool
    , isChangingDeck : Bool
    , isEditingDeck : Bool
    }


type alias Model =
    { step : Int
    , decks : Decks
    , sidebar : Sidebar
    }

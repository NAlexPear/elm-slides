module Types exposing (..)

import Array exposing (Array)


type alias Slide =
    { content : String
    , id : Int
    }


type alias Deck =
    { title : String
    , id : Int
    }


type alias Slides =
    Array Slide


type alias Decks =
    Array Deck


type alias Model =
    { step : Int
    , deck : Int
    , decks : Decks
    , slides : Slides
    , isEditing : Bool
    , isChangingDeck : Bool
    , isEditingDeck : Bool
    }

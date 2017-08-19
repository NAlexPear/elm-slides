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
    Array Deck


type alias Model =
    { step : Int
    , deck : Deck
    , title : String
    , decks : Decks
    , isEditing : Bool
    , isChangingDeck : Bool
    , isEditingDeck : Bool
    }

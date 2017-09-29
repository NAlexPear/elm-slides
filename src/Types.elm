module Types exposing (..)

import Array exposing (Array)
import Navigation exposing (Location)
import Touch exposing (Coordinates)


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


type alias Params =
    { edit : Bool }


type alias History =
    List Location


type alias AuthUser =
    { name : String
    , id : Int
    }


type Route
    = Presentation String (Maybe String)


type Sidebar
    = EditingSlide
    | ChangingDeck
    | EditingDeck
    | Inactive
    | Disabled


type User
    = Anonymous
    | Authorized AuthUser


type alias Model =
    { decks : Decks
    , sidebar : Sidebar
    , history : History
    , swipe : Coordinates
    , user : User
    }

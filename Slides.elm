module Slides exposing (Slide, list, getSlides)

import Message exposing (Msg(..))
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Http


type alias Slide =
    { title : String, content : String }


slideDecoder : Decoder Slide
slideDecoder =
    decode Slide
        |> required "title" string
        |> required "content" string


getSlides : Cmd Msg
getSlides =
    let
        request =
            Http.get "http://localhost:3000/test" slideDecoder
    in
        Http.send NewSlides request


list : List Slide
list =
    [ { title = "Slide 1"
      , content = "This should be the first slide"
      }
    , { title = "Slide 2"
      , content = "This should be the second slide"
      }
    , { title = "Slide 3"
      , content = "This should be the third slide"
      }
    ]

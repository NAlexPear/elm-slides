module Slides exposing (Slide, list)


type alias Slide =
    { title : String, content : String }


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

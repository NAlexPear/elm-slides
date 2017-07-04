module Message exposing (Msg(..))

import Keyboard exposing (KeyCode)
import Http


type alias Slide =
    { title : String, content : String }


type alias Slides =
    List Slide


type Msg
    = KeyPress KeyCode
    | GetSlides (Result Http.Error Slides)
    | AddSlide
    | ToggleEdit

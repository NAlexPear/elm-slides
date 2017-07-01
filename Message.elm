module Message exposing (Msg(..))

import Keyboard exposing (KeyCode)
import Http


type alias Slide =
    { title : String, content : String }


type Msg
    = KeyPress KeyCode
    | NewSlides (Result Http.Error Slide)

module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Keyboard exposing (KeyCode, ups)
import Message exposing (Msg(..))
import Slides


type alias Step =
    Int


type alias Slide =
    { title : String, content : String }


type alias Model =
    { step : Step, slides : List Slide, isEditing : Bool }


navigate : Model -> KeyCode -> Int
navigate model code =
    let
        step =
            model.step

        slides =
            model.slides
    in
        case code of
            39 ->
                clamp 0 (step + 1) ((List.length slides) - 1)

            37 ->
                clamp 0 step (step - 1)

            _ ->
                step


renderSlide : Model -> Slides.Slide -> List (Html Msg) -> List (Html Msg)
renderSlide model slide acc =
    let
        vw =
            ((List.length acc) - (model.step)) * 100

        position =
            ( "left", toString (vw) ++ "vw" )

        next =
            [ div
                [ class "slide"
                , style [ position ]
                ]
                [ img
                    [ class "edit pointer"
                    , src "icons/edit.svg"
                    ]
                    [ text "EDIT SLIDE" ]
                , span
                    [ class "add pointer" ]
                    [ text "+" ]
                , h1
                    []
                    [ text slide.title ]
                , p
                    []
                    [ text slide.content ]
                ]
            ]
    in
        List.append acc next



-- model


init : ( Model, Cmd Msg )
init =
    ( { step = 0, slides = [], isEditing = False }, Slides.getSlides )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPress code ->
            ( { model | step = navigate model code }, Cmd.none )

        NewSlides (Ok newSlides) ->
            ( { model | slides = newSlides }, Cmd.none )

        NewSlides (Err _) ->
            ( model, Cmd.none )

        ToggleEdit ->
            ( model, Cmd.none )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    ups KeyPress



-- view


view : Model -> Html Msg
view model =
    div
        []
        [ node "link" [ rel "stylesheet", href "main.css" ] []
        , div
            [ id "container" ]
            (List.foldl (renderSlide model) [] model.slides)
        ]


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

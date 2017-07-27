module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Keyboard exposing (KeyCode, ups)
import Message exposing (Msg(..))
import Slides


type alias Slide =
    { title : String, content : String, id : Int }


type alias Deck =
    { title : String, id : Int }


type alias Model =
    { step : Int
    , deck : Int
    , decks : List Deck
    , slides : List Slide
    , isEditing : Bool
    , isChangingDeck : Bool
    }


navigate : Model -> KeyCode -> Int
navigate model code =
    let
        step =
            model.step

        slides =
            model.slides

        ultimate =
            List.length slides

        penultimate =
            ultimate - 1
    in
        case code of
            39 ->
                penultimate
                    |> clamp 0 (step + 1)

            37 ->
                (step - 1)
                    |> clamp 0 step

            _ ->
                step


addSlide : Model -> Model
addSlide model =
    let
        end =
            List.length model.slides

        slide =
            { title = "Click to Add Title"
            , content = "Click to Add Content"
            , id = end + 1
            }

        slides =
            slide
                |> List.singleton
                |> List.append model.slides
    in
        { step = end
        , deck = model.deck
        , decks = model.decks
        , slides = slides
        , isEditing = True
        , isChangingDeck = False
        }


renderIcons : Model -> List (Html Msg)
renderIcons model =
    case model.isEditing of
        True ->
            [ img
                [ class "edit pointer"
                , src "icons/edit.svg"
                , alt "Save Slides"
                , onClick QueueSave
                ]
                []
            ]

        False ->
            [ img
                [ class "edit pointer"
                , src "icons/edit.svg"
                , alt "Edit Slides"
                , onClick ToggleEdit
                ]
                []
            , span
                [ class "add pointer"
                , onClick AddSlide
                ]
                [ text "+" ]
            , img
                [ class "change pointer"
                , src "icons/folder.png"
                , onClick ToggleChangeDeck
                ]
                []
            ]


renderFields : Model -> Slide -> List (Html Msg)
renderFields model slide =
    let
        editState =
            contenteditable model.isEditing
    in
        [ h1
            [ editState ]
            [ text slide.title ]
        , p
            [ editState ]
            [ text slide.content ]
        ]


renderSlide : Model -> Slide -> List (Html Msg) -> List (Html Msg)
renderSlide model slide acc =
    let
        currentLength =
            List.length acc

        vw =
            (currentLength - model.step) * 100

        position =
            ( "left", toString vw ++ "vw" )

        next =
            [ div
                [ class "slide"
                , style [ position ]
                ]
                (List.concat
                    [ (renderIcons model)
                    , (renderFields model slide)
                    ]
                )
            ]
    in
        List.append acc next



-- model


init : ( Model, Cmd Msg )
init =
    let
        deck =
            1
    in
        ( { step = 0
          , deck = deck
          , decks = []
          , slides = []
          , isEditing = False
          , isChangingDeck = False
          }
        , Slides.getSlides deck
        )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPress code ->
            ( { model | step = navigate model code }, Cmd.none )

        GetSlides (Ok newSlides) ->
            ( { model | slides = newSlides }, Cmd.none )

        GetSlides (Err _) ->
            ( model, Cmd.none )

        GetDecks (Ok newDecks) ->
            ( { model | decks = newDecks }, Cmd.none )

        GetDecks (Err _) ->
            ( model, Cmd.none )

        SaveSlides (Ok newSlides) ->
            ( { model
                | slides = newSlides
                , isEditing = not model.isEditing
              }
            , Cmd.none
            )

        SaveSlides (Err _) ->
            ( model, Cmd.none )

        QueueSave ->
            ( model, (Slides.saveSlides model.slides model.deck) )

        ToggleEdit ->
            ( { model | isEditing = not model.isEditing }, Cmd.none )

        ToggleChangeDeck ->
            ( { model | isChangingDeck = not model.isChangingDeck }, Slides.getDecks )

        AddSlide ->
            ( addSlide model, Cmd.none )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    ups KeyPress



-- view


view : Model -> Html Msg
view model =
    let
        renderer =
            renderSlide model
    in
        div
            []
            [ node "link" [ rel "stylesheet", href "main.css" ] []
            , model.slides
                |> List.foldl renderer []
                |> div [ id "container" ]
            ]


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

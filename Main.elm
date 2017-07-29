module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Keyboard exposing (KeyCode, ups)
import Message exposing (Msg(..))
import Types exposing (..)
import Array exposing (Array)
import Array
import Markdown
import Slides


navigate : Model -> KeyCode -> Int
navigate model code =
    let
        step =
            model.step

        slides =
            model.slides

        ultimate =
            Array.length slides

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
            Array.length model.slides

        slide =
            { content = "# Click Edit Button \n ...and add some content!"
            , id = end + 1
            }

        slides =
            Array.empty
                |> Array.push slide
                |> Array.append model.slides
    in
        { model
            | step = end
            , slides = slides
            , isEditing = True
            , isChangingDeck = False
        }


renderIcons : Model -> List (Html Msg)
renderIcons model =
    case model.isEditing of
        True ->
            [ span
                [ class "edit pointer fa fa-pencil-square-o"
                , alt "Save Slides"
                , onClick QueueSave
                ]
                []
            ]

        False ->
            [ span
                [ class "edit pointer fa fa-pencil-square-o"
                , alt "Edit Slides"
                , onClick ToggleEdit
                ]
                []
            , span
                [ class "add pointer fa fa-plus"
                , onClick AddSlide
                ]
                []
            , span
                [ class "change pointer fa fa-exchange"
                , onClick ToggleChangeDeck
                ]
                []
            ]


renderFields : Model -> Slide -> List (Html Msg)
renderFields model slide =
    case model.isEditing of
        True ->
            [ textarea
                [ value slide.content
                , onInput UpdateContent
                ]
                []
            ]

        False ->
            [ div
                []
                [ Markdown.toHtml [] slide.content ]
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
            [ slide
                |> renderFields model
                |> div
                    [ class "slide"
                    , style [ position ]
                    ]
            ]
    in
        List.append acc next


updateSlides : Model -> String -> Array Slide
updateSlides model newContent =
    let
        id =
            model.step + 1

        slide =
            { content = newContent
            , id = id
            }
    in
        Array.set model.step slide model.slides



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
          , slides = Array.empty
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

        UpdateContent newContent ->
            ( { model | slides = updateSlides model newContent }, Cmd.none )



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

        icons =
            model
                |> renderIcons
                |> div [ id "icons" ]
                |> List.singleton
    in
        div
            []
            [ node "link" [ rel "stylesheet", href "//cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" ] []
            , node "link" [ rel "stylesheet", href "main.css" ] []
            , model.slides
                |> Array.foldl renderer []
                |> List.append icons
                |> div [ id "container" ]
            ]


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
import Array exposing (Array)
import Message exposing (Msg(..))
import Keyboard exposing (ups)
import Renderers exposing (renderIcons, renderSlide)
import Requests exposing (getSlides, saveSlides, getDecks)
import Navigators exposing (navigate)
import Array


addSlide : Model -> Model
addSlide model =
    let
        end =
            Array.length model.slides

        slide =
            { content = "# This is a new slide \n ...and add some content!"
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


initiateSlideSave : Model -> Cmd Msg
initiateSlideSave model =
    saveSlides model.slides model.deck


mapKeyToMsg : Model -> Int -> Cmd Msg
mapKeyToMsg model code =
    let
        save =
            case model.isEditing of
                True ->
                    initiateSlideSave model

                False ->
                    Cmd.none
    in
        case code of
            27 ->
                save

            _ ->
                Cmd.none


handleEditHotkey : Model -> Int -> Bool
handleEditHotkey model code =
    case code of
        69 ->
            True

        _ ->
            model.isEditing


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
        , getSlides deck
        )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPress code ->
            ( { model
                | step = navigate model code
                , isEditing = handleEditHotkey model code
              }
            , mapKeyToMsg model code
            )

        GetSlides (Ok newSlides) ->
            ( { model
                | slides = newSlides
              }
            , Cmd.none
            )

        GetSlides (Err _) ->
            ( model, Cmd.none )

        GetDecks (Ok newDecks) ->
            ( { model
                | decks = newDecks
              }
            , Cmd.none
            )

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
            ( model, initiateSlideSave model )

        ToggleEdit ->
            ( { model
                | isEditing = not model.isEditing
              }
            , Cmd.none
            )

        ToggleChangeDeck ->
            ( { model
                | isChangingDeck = not model.isChangingDeck
              }
            , getDecks
            )

        ChangeDeck deck ->
            ( { model
                | isChangingDeck = False
                , deck = deck
              }
            , getSlides deck
            )

        AddSlide ->
            ( addSlide model, Cmd.none )

        UpdateContent newContent ->
            ( { model
                | slides = updateSlides model newContent
              }
            , Cmd.none
            )



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

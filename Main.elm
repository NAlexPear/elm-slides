module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
import Array exposing (Array)
import Message exposing (Msg(..))
import Components exposing (icons, slide)
import Keyboard exposing (ups)
import Requests exposing (getSlides, saveSlides, getDecks, saveDeck)
import Navigators exposing (navigate)
import Array


mapIdToIndex : Int -> Slide -> Slide
mapIdToIndex index slide =
    let
        id =
            index + 1
    in
        { slide | id = id }


addSlide : Model -> Model
addSlide model =
    let
        slide =
            { content = "# This is a new slide \n ...and add some content!"
            , id = model.step
            }

        length =
            Array.length model.slides

        head =
            model.slides
                |> Array.slice 0 model.step
                |> Array.push slide

        tail =
            model.slides
                |> Array.slice model.step length

        slides =
            tail
                |> Array.append head
                |> Array.indexedMap mapIdToIndex
    in
        { model
            | slides = slides
            , isEditing = True
            , isChangingDeck = False
        }


updateSlides : Model -> String -> Slides
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


updateDecks : Model -> Deck -> Decks
updateDecks model newDeck =
    let
        index =
            newDeck.id - 1
    in
        Array.set index newDeck model.decks


initiateDeckSave : Model -> Cmd Msg
initiateDeckSave model =
    let
        index =
            model.deck - 1

        maybeDeck =
            Array.get index model.decks
    in
        case maybeDeck of
            Just deck ->
                saveDeck { deck | title = model.title }

            Nothing ->
                Cmd.none


initiateSlideSave : Model -> Cmd Msg
initiateSlideSave model =
    saveSlides model.slides model.deck


rejectSlideById : Int -> Slide -> Bool
rejectSlideById id slide =
    slide.id /= id


initiateSlideDelete : Model -> Cmd Msg
initiateSlideDelete model =
    let
        id =
            model.step + 1

        predicate =
            rejectSlideById id

        slides =
            model.slides
                |> Array.filter predicate
                |> Array.indexedMap mapIdToIndex
    in
        saveSlides slides model.deck


mapKeyToMsg : Model -> Int -> Cmd Msg
mapKeyToMsg model code =
    let
        save =
            if model.isEditing then
                initiateSlideSave model
            else
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
            not model.isEditingDeck

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
          , title = ""
          , decks = Array.empty
          , slides = Array.empty
          , isEditing = False
          , isChangingDeck = False
          , isEditingDeck = False
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
                , isEditing = False
              }
            , Cmd.none
            )

        SaveSlides (Err _) ->
            ( model, Cmd.none )

        SaveDeck (Ok newDeck) ->
            ( { model
                | decks = updateDecks model newDeck
              }
            , Cmd.none
            )

        SaveDeck (Err _) ->
            ( model, Cmd.none )

        QueueSave ->
            ( model, initiateSlideSave model )

        QueueDelete ->
            ( model, initiateSlideDelete model )

        QueueSaveDeck ->
            ( model, initiateDeckSave model )

        ToggleEdit ->
            ( { model
                | isEditing = not model.isEditing
              }
            , Cmd.none
            )

        ToggleChangeDeck ->
            ( { model
                | isChangingDeck = not model.isChangingDeck
                , isEditingDeck = False
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

        ToggleEditDeck ->
            ( { model
                | isChangingDeck = False
                , isEditingDeck = not model.isEditingDeck
              }
            , getDecks
            )

        AddSlide ->
            ( addSlide model, Cmd.none )

        UpdateContent newContent ->
            ( { model
                | slides = updateSlides model newContent
              }
            , Cmd.none
            )

        UpdateTitle newTitle ->
            ( { model
                | title = newTitle
              }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    ups KeyPress



-- view


view : Model -> Html Msg
view model =
    let
        renderer =
            slide model

        iconClasses =
            if model.isChangingDeck || model.isEditingDeck then
                "active"
            else
                ""

        sidebar =
            model
                |> icons
                |> div [ id "icons", class iconClasses ]
                |> List.singleton
    in
        div
            []
            [ node "link" [ rel "stylesheet", href "//cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" ] []
            , node "link" [ rel "stylesheet", href "main.css" ] []
            , model.slides
                |> Array.foldl renderer []
                |> List.append sidebar
                |> div [ id "container" ]
            ]


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

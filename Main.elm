module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
import Array exposing (Array)
import Message exposing (Msg(..))
import Components exposing (icons, slide)
import Keyboard exposing (ups)
import Requests exposing (getDeck, getDecks, saveDeck)
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
            Array.length model.decks.current.slides

        head =
            model.decks.current.slides
                |> Array.slice 0 model.step
                |> Array.push slide

        tail =
            model.decks.current.slides
                |> Array.slice model.step length

        slides =
            tail
                |> Array.append head
                |> Array.indexedMap mapIdToIndex

        decks =
            model.decks

        deck =
            decks.current

        newDeck =
            { deck | slides = slides }

        newDecks =
            { decks | current = deck }
    in
        { model
            | decks = newDecks
            , isEditing = True
            , isChangingDeck = False
        }


updateTitle : Deck -> String -> Deck
updateTitle deck newTitle =
    { deck | title = newTitle }


updateSlides : Model -> String -> Deck
updateSlides model newContent =
    let
        id =
            model.step + 1

        deck =
            model.decks.current

        slide =
            { content = newContent
            , id = id
            }

        slides =
            Array.set model.step slide deck.slides
    in
        { deck | slides = slides }


initiateSlideSave : Model -> Cmd Msg
initiateSlideSave model =
    saveDeck model.decks.current


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

        deck =
            model.decks.current

        slides =
            model.decks.current.slides
                |> Array.filter predicate
                |> Array.indexedMap mapIdToIndex

        newDeck =
            { deck | slides = slides }
    in
        saveDeck deck


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
        current =
            { title = ""
            , id = 1
            , slides = Array.empty
            }
    in
        ( { step = 0
          , decks = { current = current, others = Array.empty }
          , isEditing = False
          , isChangingDeck = False
          , isEditingDeck = False
          }
        , getDeck 1
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

        GetDeck (Ok current) ->
            ( let
                decks =
                    model.decks

                newDecks =
                    { decks | current = current }
              in
                { model
                    | decks = newDecks
                }
            , Cmd.none
            )

        GetDeck (Err _) ->
            ( model, Cmd.none )

        GetDecks (Ok others) ->
            ( let
                decks =
                    model.decks

                newDecks =
                    { decks | others = others }
              in
                { model
                    | decks = newDecks
                }
            , Cmd.none
            )

        GetDecks (Err _) ->
            ( model, Cmd.none )

        SaveDeck (Ok newDeck) ->
            ( let
                decks =
                    model.decks

                newDecks =
                    { decks | current = newDeck }
              in
                { model | decks = newDecks }
            , Cmd.none
            )

        SaveDeck (Err _) ->
            ( model, Cmd.none )

        QueueSaveDeck ->
            ( model, saveDeck model.decks.current )

        QueueSave ->
            ( model, initiateSlideSave model )

        QueueDelete ->
            ( model, initiateSlideDelete model )

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
              }
            , getDeck deck
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
            ( let
                decks =
                    model.decks

                newDecks =
                    { decks | current = updateSlides model newContent }
              in
                { model
                    | decks = newDecks
                }
            , Cmd.none
            )

        UpdateTitle newTitle ->
            ( let
                decks =
                    model.decks

                newDecks =
                    { decks | current = updateTitle model.decks.current newTitle }
              in
                { model
                    | decks = newDecks
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
            , model.decks.current.slides
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

module Update exposing (update)

import Debug
import Message exposing (Msg(..))
import Navigation exposing (newUrl)
import Navigators exposing (navigate, getDeckId)
import Ports exposing (highlight)
import Requests exposing (createDeck, getDeck, getDecks, saveDeck)
import Types exposing (..)
import Updaters exposing (..)


mapKeyToMsg : Model -> Int -> Cmd Msg
mapKeyToMsg { decks, sidebar } code =
    if code == 27 && sidebar == EditingSlide then
        saveDeck decks.current
    else
        Cmd.none


handleEditHotkey : Sidebar -> Int -> Sidebar
handleEditHotkey sidebar code =
    if code == 69 && sidebar /= EditingDeck then
        EditingSlide
    else
        sidebar


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPress code ->
            ( { model
                | decks = navigate model code
                , sidebar = handleEditHotkey model.sidebar code
              }
            , mapKeyToMsg model code
            )

        GetDeck (Ok newCurrentDeck) ->
            ( let
                newModel =
                    updateCurrentDeck model newCurrentDeck
              in
                { newModel | sidebar = Inactive }
            , highlight "Starting highlight.js"
            )

        GetDeck (Err error) ->
            ( Debug.crash <| toString error, Cmd.none )

        GetDecks (Ok newOtherDecks) ->
            ( updateOtherDecks model newOtherDecks
            , Cmd.none
            )

        GetDecks (Err _) ->
            ( model, Cmd.none )

        SaveDeck (Ok newCurrentDeck) ->
            ( { model | sidebar = Inactive }
            , highlight "Reloading highlight.js"
            )

        SaveDeck (Err _) ->
            ( model, Cmd.none )

        QueueSave ->
            ( model, saveDeck model.decks.current )

        QueueDelete ->
            ( model, deleteSlide model.decks )

        ToggleEdit ->
            ( { model
                | sidebar =
                    case model.sidebar of
                        EditingSlide ->
                            Inactive

                        _ ->
                            EditingSlide
              }
            , Cmd.none
            )

        ToggleChangeDeck ->
            ( { model
                | sidebar =
                    case model.sidebar of
                        ChangingDeck ->
                            Inactive

                        _ ->
                            ChangingDeck
              }
            , getDecks
            )

        ChangeDeck deckId ->
            ( { model | sidebar = Inactive }
            , deckId
                |> toString
                |> (++) "/decks/"
                |> flip (++) "#1"
                |> newUrl
            )

        ToggleEditDeck ->
            ( { model
                | sidebar =
                    case model.sidebar of
                        EditingDeck ->
                            Inactive

                        _ ->
                            EditingDeck
              }
            , getDecks
            )

        AddSlide ->
            ( addSlide model, Cmd.none )

        CreateDeck ->
            ( model, createDeck )

        UpdateSlide newContent ->
            ( updateSlide model newContent
            , Cmd.none
            )

        UpdateDeckTitle newTitle ->
            ( let
                deck =
                    model.decks.current
              in
                updateCurrentDeck model { deck | title = newTitle }
            , Cmd.none
            )

        UrlChange location ->
            ( { model | history = location :: model.history }
            , location
                |> getDeckId
                |> getDeck
            )

        NoOp ->
            ( model, Cmd.none )

module Update exposing (update)

import Message exposing (Msg(..))
import Navigators exposing (navigate)
import Requests exposing (saveDeck, getDeck, getDecks)
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
            , Cmd.none
            )

        GetDeck (Err _) ->
            ( model, Cmd.none )

        GetDecks (Ok newOtherDecks) ->
            ( updateOtherDecks model newOtherDecks
            , Cmd.none
            )

        GetDecks (Err _) ->
            ( model, Cmd.none )

        SaveDeck (Ok newCurrentDeck) ->
            ( let
                newModel =
                    updateCurrentDeck model newCurrentDeck
              in
                { newModel | sidebar = Inactive }
            , Cmd.none
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

        ChangeDeck deck ->
            ( { model | sidebar = Inactive }
            , getDeck deck
            )

        ToggleEditDeck ->
            ( let
                newSidebar =
                    case model.sidebar of
                        EditingDeck ->
                            Inactive

                        _ ->
                            EditingDeck
              in
                { model | sidebar = newSidebar }
            , getDecks
            )

        AddSlide ->
            ( addSlide model, Cmd.none )

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

        NoOp ->
            ( model, Cmd.none )

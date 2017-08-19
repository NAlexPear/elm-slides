module Update exposing (update)

import Initiators exposing (initiateSlideSave, initiateSlideDelete)
import Message exposing (Msg(..))
import Navigators exposing (navigate)
import Requests exposing (saveDeck, getDeck, getDecks)
import Types exposing (..)
import Updaters exposing (updateTitle, updateSlides, addSlide)


mapKeyToMsg : Model -> Int -> Cmd Msg
mapKeyToMsg model code =
    if code == 27 && model.sidebar == EditingSlide then
        initiateSlideSave model
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
                | step = navigate model code
                , sidebar = handleEditHotkey model.sidebar code
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
                { model
                    | decks = newDecks
                    , sidebar = Inactive
                }
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
            ( let
                newSidebar =
                    case model.sidebar of
                        EditingSlide ->
                            Inactive

                        _ ->
                            EditingSlide
              in
                { model | sidebar = newSidebar }
            , Cmd.none
            )

        ToggleChangeDeck ->
            ( let
                newSidebar =
                    case model.sidebar of
                        ChangingDeck ->
                            Inactive

                        _ ->
                            ChangingDeck
              in
                { model | sidebar = newSidebar }
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
                { model | decks = newDecks }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )

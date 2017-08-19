module Update exposing (update)

import Initiators exposing (initiateSlideSave, initiateSlideDelete)
import Message exposing (Msg(..))
import Navigators exposing (navigate)
import Requests exposing (saveDeck, getDeck, getDecks)
import Types exposing (..)
import Updaters exposing (updateTitle, updateSlides, addSlide)


mapKeyToMsg : Model -> Int -> Cmd Msg
mapKeyToMsg model code =
    let
        save =
            if model.sidebar.isEditing then
                initiateSlideSave model
            else
                Cmd.none
    in
        case code of
            27 ->
                save

            _ ->
                Cmd.none


handleEditHotkey : Sidebar -> Int -> Sidebar
handleEditHotkey sidebar code =
    let
        isEditing =
            case code of
                69 ->
                    not sidebar.isEditingDeck

                _ ->
                    sidebar.isEditing
    in
        { sidebar | isEditing = isEditing }


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
            ( let
                sidebar =
                    model.sidebar

                newSidebar =
                    { sidebar | isEditing = not sidebar.isEditing }
              in
                { model | sidebar = newSidebar }
            , Cmd.none
            )

        ToggleChangeDeck ->
            ( let
                sidebar =
                    model.sidebar

                newSidebar =
                    { sidebar
                        | isChangingDeck = not sidebar.isChangingDeck
                        , isEditing = False
                    }
              in
                { model | sidebar = newSidebar }
            , getDecks
            )

        ChangeDeck deck ->
            ( let
                sidebar =
                    model.sidebar

                newSidebar =
                    { sidebar | isChangingDeck = False }
              in
                { model | sidebar = newSidebar }
            , getDeck deck
            )

        ToggleEditDeck ->
            ( let
                sidebar =
                    model.sidebar

                newSidebar =
                    { sidebar
                        | isChangingDeck = False
                        , isEditing = not sidebar.isEditingDeck
                    }
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
                { model
                    | decks = newDecks
                }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )

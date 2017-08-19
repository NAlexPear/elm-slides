module Update exposing (update)

import Initiators exposing (initiateSlideSave, initiateSlideDelete)
import Message exposing (Msg(..))
import Navigators exposing (navigate)
import Requests exposing (saveDeck, getDeck, getDecks)
import Types exposing (Model)
import Updaters exposing (updateTitle, updateSlides, addSlide)


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

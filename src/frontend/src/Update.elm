module Update exposing (update)

import Navigators
    exposing
        ( getDeckId
        , navigate
        )
import Ports
    exposing
        ( authorize
        , highlight
        , getToken
        )
import Requests
    exposing
        ( createDeck
        , deleteDeck
        , getDeck
        , getDecks
        , saveDeck
        )
import Array
import Debug
import Message exposing (Msg(..))
import Navigation
import Types exposing (..)
import Updaters exposing (..)
import UrlParser as Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPress code ->
            ( let
                sidebar =
                    case model.sidebar of
                        Disabled ->
                            model.sidebar

                        _ ->
                            handleEditHotkey model.sidebar code
              in
                { model
                    | decks = navigate model code
                    , sidebar = sidebar
                }
            , mapKeyToMsg model code
            )

        SwipeStart coordinates ->
            ( { model | swipe = coordinates }, Cmd.none )

        SwipeEnd { clientX } ->
            ( let
                previousX =
                    model.swipe.clientX

                keyCode =
                    if previousX > clientX then
                        39
                    else
                        37
              in
                { model
                    | decks = navigate model keyCode
                }
            , Cmd.none
            )

        GetDeck (Ok newCurrentDeck) ->
            ( let
                newModel =
                    updateCurrentDeck model newCurrentDeck

                sidebar =
                    case model.sidebar of
                        Disabled ->
                            Disabled

                        _ ->
                            Inactive
              in
                { newModel | sidebar = sidebar }
            , highlight "Starting highlight.js"
            )

        GetDeck (Err error) ->
            ( model, moveToFirstDeck model.decks )

        GetDecks (Ok newOtherDecks) ->
            ( updateOtherDecks model newOtherDecks
            , Cmd.none
            )

        GetDecks (Err _) ->
            ( model, Cmd.none )

        SaveDeck (Ok _) ->
            ( let
                sidebar =
                    case model.sidebar of
                        Disabled ->
                            Disabled

                        _ ->
                            Inactive
              in
                { model | sidebar = sidebar }
            , highlight "Reloading highlight.js"
            )

        SaveDeck (Err error) ->
            ( Debug.crash <| toString error, Cmd.none )

        DeleteDeck (Ok _) ->
            ( let
                sidebar =
                    case model.sidebar of
                        Disabled ->
                            Disabled

                        _ ->
                            Inactive
              in
                { model | sidebar = sidebar }
            , moveToFirstDeck model.decks
            )

        DeleteDeck (Err error) ->
            ( Debug.crash <| toString error
            , Cmd.none
            )

        QueueSave ->
            ( model, saveDeck model.decks.current )

        QueueSlideDelete ->
            ( model, deleteSlide model.decks )

        QueueDeckDelete ->
            ( model
            , if Array.length model.decks.others > 0 then
                deleteDeck model.decks.current
              else
                Cmd.none
            )

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

        ChangeDeck title ->
            ( { model | sidebar = Inactive }
            , changeDeck title
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

        Authenticate ->
            ( model, authorize "Delegating to auth0" )

        Login (Ok { token, previousDeck }) ->
            ( let
                newUser =
                    AuthUser 1 "test" token
              in
                { model
                    | user = Authorized newUser
                    , sidebar = Inactive
                }
            , Navigation.modifyUrl <| previousDeck ++ "?edit=true"
            )

        Login (Err error) ->
            ( model
            , Debug.crash error
            )

        Logout ->
            ( { model | user = Anonymous }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

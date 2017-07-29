module Components exposing (slide, icons)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (..)
import Message exposing (Msg(..))
import Markdown


deckItem : Deck -> Html Msg
deckItem deck =
    let
        clickHandler =
            ChangeDeck deck.id
    in
        li
            [ class "pointer"
            , onClick clickHandler
            ]
            [ text deck.title ]


deckItems : Decks -> List (Html Msg)
deckItems decks =
    List.map deckItem decks


deckMenu : Model -> Html Msg
deckMenu model =
    let
        hiddenString =
            if model.isChangingDeck then
                ""
            else
                " hidden"

        classString =
            "menu" ++ hiddenString
    in
        div [ id "decks", class classString ]
            [ model.decks
                |> deckItems
                |> ul []
            ]


fields : Model -> Slide -> List (Html Msg)
fields model slide =
    if model.isEditing then
        [ textarea
            [ value slide.content
            , onInput UpdateContent
            ]
            []
        ]
    else
        [ div
            []
            [ Markdown.toHtml [] slide.content ]
        ]


icons : Model -> List (Html Msg)
icons model =
    if model.isEditing then
        [ span
            [ class "edit pointer fa fa-pencil-square-o"
            , alt "Save Slides"
            , onClick QueueSave
            ]
            []
        ]
    else
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
            [ class "pointer fa fa-trash"
            , onClick QueueDelete
            ]
            []
        , deckMenu model
            |> List.singleton
            |> span
                [ class "change pointer fa fa-exchange"
                , onClick ToggleChangeDeck
                ]
        , span
            [ class "pointer fa fa-gear" ]
            []
        ]


slide : Model -> Slide -> List (Html Msg) -> List (Html Msg)
slide model slide acc =
    let
        currentLength =
            List.length acc

        vw =
            (currentLength - model.step) * 100

        position =
            ( "left", toString vw ++ "vw" )

        next =
            [ slide
                |> fields model
                |> div
                    [ class "slide"
                    , style [ position ]
                    ]
            ]
    in
        List.append acc next

module Renderers exposing (renderSlide, renderIcons)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (..)
import Message exposing (Msg(..))
import Markdown


renderDeckLink : Deck -> Html Msg
renderDeckLink deck =
    let
        clickHandler =
            ChangeDeck deck.id
    in
        li
            [ class "pointer"
            , onClick clickHandler
            ]
            [ text deck.title ]


renderDeckLinks : Decks -> List (Html Msg)
renderDeckLinks decks =
    List.map renderDeckLink decks


renderDeckModal : Model -> Html Msg
renderDeckModal model =
    let
        classString =
            if model.isChangingDeck then
                ""
            else
                "hidden"
    in
        div [ id "decks", class classString ]
            [ model.decks
                |> renderDeckLinks
                |> ul []
            ]


renderFields : Model -> Slide -> List (Html Msg)
renderFields model slide =
    case model.isEditing of
        True ->
            [ textarea
                [ value slide.content
                , onInput UpdateContent
                ]
                []
            ]

        False ->
            [ div
                []
                [ Markdown.toHtml [] slide.content ]
            ]


renderIcons : Model -> List (Html Msg)
renderIcons model =
    case model.isEditing of
        True ->
            [ span
                [ class "edit pointer fa fa-pencil-square-o"
                , alt "Save Slides"
                , onClick QueueSave
                ]
                []
            ]

        False ->
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
                [ class "change pointer fa fa-exchange"
                , onClick ToggleChangeDeck
                ]
                []
            , renderDeckModal model
            ]


renderSlide : Model -> Slide -> List (Html Msg) -> List (Html Msg)
renderSlide model slide acc =
    let
        currentLength =
            List.length acc

        vw =
            (currentLength - model.step) * 100

        position =
            ( "left", toString vw ++ "vw" )

        next =
            [ slide
                |> renderFields model
                |> div
                    [ class "slide"
                    , style [ position ]
                    ]
            ]
    in
        List.append acc next

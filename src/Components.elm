module Components exposing (slide, icons)

import Array
import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Markdown
import Message exposing (Msg(..))
import Types exposing (..)


getHiddenString : Bool -> String
getHiddenString trigger =
    if trigger then
        ""
    else
        " hidden"


deckItem : Deck -> Html Msg
deckItem { id, title } =
    let
        clickHandler =
            ChangeDeck id
    in
        li
            [ class "pointer"
            , onClick clickHandler
            ]
            [ text title ]


deckItems : Decks -> List (Html Msg)
deckItems { others } =
    others
        |> Array.map deckItem
        |> Array.toList


deckMenu : Model -> Html Msg
deckMenu { decks, sidebar } =
    let
        trigger =
            sidebar == ChangingDeck

        hiddenString =
            getHiddenString trigger

        classString =
            "menu" ++ hiddenString
    in
        div [ class classString ]
            [ decks
                |> deckItems
                |> ul []
            ]


deckSettingsForm : Deck -> Html Msg
deckSettingsForm { title } =
    let
        clickHandler =
            NoOp
                |> Decode.succeed
                |> onWithOptions "click" { stopPropagation = True, preventDefault = True }
    in
        div [ id "settings", clickHandler ]
            [ label
                [ for "title" ]
                [ text "Deck Title:"
                , input
                    [ placeholder title
                    , name "title"
                    , onInput UpdateDeckTitle
                    ]
                    []
                ]
            , button
                [ class "pointer", onClick QueueSave ]
                [ text "Save Changes" ]
            ]


deckSettingsMenu : Model -> Html Msg
deckSettingsMenu { decks, sidebar } =
    let
        trigger =
            sidebar == EditingDeck

        hiddenString =
            getHiddenString trigger

        classString =
            "menu" ++ hiddenString
    in
        div [ class classString ] [ deckSettingsForm decks.current ]


fields : Sidebar -> Slide -> List (Html Msg)
fields sidebar { content } =
    case sidebar of
        EditingSlide ->
            [ textarea
                [ value content
                , onInput UpdateSlide
                ]
                []
            ]

        _ ->
            [ div
                []
                [ Markdown.toHtml [] content ]
            ]


icons : Model -> List (Html Msg)
icons model =
    case model.sidebar of
        EditingSlide ->
            [ span
                [ class "edit fa fa-pencil-square-o"
                , alt "Save Slides"
                , onClick QueueSave
                ]
                []
            ]

        _ ->
            [ span
                [ class "edit fa fa-pencil-square-o"
                , alt "Edit Slides"
                , onClick ToggleEdit
                ]
                []
            , span
                [ class "add fa fa-plus"
                , onClick AddSlide
                ]
                []
            , span
                [ class "fa fa-trash"
                , onClick QueueDelete
                ]
                []
            , deckMenu model
                |> List.singleton
                |> span
                    [ class "change fa fa-exchange"
                    , onClick ToggleChangeDeck
                    ]
            , deckSettingsMenu model
                |> List.singleton
                |> span
                    [ class "settings fa fa-gear"
                    , onClick ToggleEditDeck
                    ]
            ]


slide : Model -> Slide -> List (Html Msg) -> List (Html Msg)
slide { decks, sidebar } slide acc =
    let
        currentLength =
            List.length acc

        previousLength =
            List.length decks.current.slides.previous

        vw =
            (currentLength - previousLength) * 100

        position =
            ( "left", toString vw ++ "vw" )

        next =
            [ slide
                |> fields sidebar
                |> div
                    [ class "slide"
                    , style [ position ]
                    ]
            ]
    in
        List.append acc next

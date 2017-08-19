module Components exposing (slide, icons)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (..)
import Message exposing (Msg(..))
import Array exposing (Array)
import Json.Decode as Decode
import Array
import Markdown


getHiddenString : Bool -> String
getHiddenString trigger =
    if trigger then
        ""
    else
        " hidden"


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
    decks.others
        |> Array.map deckItem
        |> Array.toList


deckMenu : Model -> Html Msg
deckMenu model =
    let
        trigger =
            model.sidebar == ChangingDeck

        hiddenString =
            getHiddenString trigger

        classString =
            "menu" ++ hiddenString
    in
        div [ class classString ]
            [ model.decks
                |> deckItems
                |> ul []
            ]


deckSettingsForm : Deck -> Html Msg
deckSettingsForm deck =
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
                    [ placeholder deck.title
                    , name "title"
                    , onInput UpdateTitle
                    ]
                    []
                ]
            , button
                [ class "pointer", onClick QueueSaveDeck ]
                [ text "Save Changes" ]
            ]


deckSettingsMenu : Model -> Html Msg
deckSettingsMenu model =
    let
        trigger =
            model.sidebar == EditingDeck

        hiddenString =
            getHiddenString trigger

        classString =
            "menu" ++ hiddenString

        index =
            model.decks.current.id - 1

        maybeDeck =
            Array.get index model.decks.others

        menu =
            case maybeDeck of
                Just deck ->
                    deckSettingsForm deck

                Nothing ->
                    text "No deck information found"
    in
        div [ class classString ] [ menu ]


fields : Sidebar -> Slide -> List (Html Msg)
fields sidebar slide =
    case sidebar of
        EditingSlide ->
            [ textarea
                [ value slide.content
                , onInput UpdateContent
                ]
                []
            ]

        _ ->
            [ div
                []
                [ Markdown.toHtml [] slide.content ]
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
                |> fields model.sidebar
                |> div
                    [ class "slide"
                    , style [ position ]
                    ]
            ]
    in
        List.append acc next

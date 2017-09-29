module View exposing (view)

import Array
import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Markdown
import Message exposing (Msg(..))
import Regex exposing (Regex, find, regex, replace)
import SingleTouch exposing (onStart, onEnd)
import Types exposing (..)


getHiddenString : Bool -> String
getHiddenString trigger =
    if trigger then
        ""
    else
        " hidden"


deckItem : Deck -> Html Msg
deckItem { id, title } =
    li
        [ class "pointer"
        , onClick <| ChangeDeck title
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
        classString =
            sidebar
                |> (==) ChangingDeck
                |> getHiddenString
                |> (++) "menu"
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
        classString =
            sidebar
                |> (==) EditingDeck
                |> getHiddenString
                |> (++) "menu"
    in
        div [ class classString ] [ deckSettingsForm decks.current ]


mapToConfig : List String -> ( String, String )
mapToConfig pair =
    case pair of
        x :: y ->
            ( x
            , case List.head y of
                Just value ->
                    value

                Nothing ->
                    ""
            )

        [] ->
            ( "display", "block" )


frontMatter : Regex
frontMatter =
    regex "^---\n(.|\n)*?---"


generateContent : String -> List (Html Msg)
generateContent content =
    let
        visible =
            replace (Regex.AtMost 1) frontMatter (\_ -> "") content
    in
        [ div
            []
            [ Markdown.toHtml [] visible ]
        ]


generateSlide : String -> ( String, String ) -> List (Html Msg) -> Html Msg
generateSlide content position children =
    let
        dividers =
            regex "(^---\n|\n---$)"

        configYaml =
            find (Regex.AtMost 1) frontMatter content

        config =
            case List.head configYaml of
                Just { match } ->
                    match
                        |> replace (Regex.AtMost 2) dividers (\_ -> "")
                        |> String.lines
                        |> List.map (Regex.split (Regex.AtMost 1) (regex ":"))
                        |> List.map mapToConfig

                Nothing ->
                    []
    in
        div
            [ class "slide"
            , style <| position :: config
            ]
            children


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
            generateContent content


icons : Model -> List (Html Msg)
icons model =
    case model.sidebar of
        EditingSlide ->
            [ span
                [ class "edit fa fa-pencil-square-o"
                , alt "Save Slides"
                , onClick QueueSave
                ]
                [ label
                    [ class "icon-label" ]
                    [ text "save" ]
                ]
            ]

        _ ->
            [ span
                [ class "edit fa fa-pencil-square-o"
                , alt "Edit Slides"
                , onClick ToggleEdit
                ]
                [ label
                    [ class "icon-label" ]
                    [ text "edit" ]
                ]
            , span
                [ class "add fa fa-plus"
                , onClick AddSlide
                ]
                [ label
                    [ class "icon-label" ]
                    [ text "add slide" ]
                ]
            , span
                [ class "fa fa-trash"
                , onClick QueueSlideDelete
                ]
                [ label
                    [ class "icon-label" ]
                    [ text "delete slide" ]
                ]
            , deckMenu model
                |> List.singleton
                |> (++)
                    [ label
                        [ class "icon-label" ]
                        [ text "switch deck" ]
                    ]
                |> span
                    [ class "change fa fa-exchange"
                    , onClick ToggleChangeDeck
                    ]
            , deckSettingsMenu model
                |> List.singleton
                |> (++)
                    [ label
                        [ class "icon-label" ]
                        [ text "deck settings" ]
                    ]
                |> span
                    [ class "settings fa fa-gear"
                    , onClick ToggleEditDeck
                    ]
            , span
                [ class "fa fa-file"
                , onClick CreateDeck
                ]
                [ label
                    [ class "icon-label" ]
                    [ text "new deck" ]
                ]
            , span
                [ class "fa fa-window-close"
                , onClick QueueDeckDelete
                ]
                [ label
                    [ class "icon-label" ]
                    [ text "delete deck" ]
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
                |> generateSlide slide.content position
            ]
    in
        List.append acc next


view : Model -> Html Msg
view ({ decks, sidebar, user } as model) =
    let
        renderer =
            slide model

        iconClasses =
            if sidebar == ChangingDeck || sidebar == EditingDeck then
                "active"
            else
                ""

        userPrompt =
            case user of
                Anonymous ->
                    [ span
                        [ class "fa fa-user" ]
                        [ label [] [ text "SIGN IN" ] ]
                    ]

                Authorized { name } ->
                    [ span
                        [ class "fa fa-logout" ]
                        [ label [] [ text <| "HI, " ++ name ] ]
                    ]

        sidebarView =
            case sidebar of
                Disabled ->
                    List.singleton <| div [] []

                _ ->
                    model
                        |> icons
                        |> div [ id "icons", class iconClasses ]
                        |> List.singleton
                        |> List.append [ button [ id "user-prompt" ] userPrompt ]

        slides =
            decks.current.slides
    in
        div
            [ onStart SwipeStart, onEnd SwipeEnd ]
            [ node "link" [ rel "stylesheet", href "//cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" ] []
            , slides.remaining
                |> List.append [ slides.current ]
                |> List.append slides.previous
                |> List.foldl renderer []
                |> List.append sidebarView
                |> div [ id "container" ]
            ]

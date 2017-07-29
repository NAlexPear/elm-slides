module Renderers exposing (renderSlide, renderIcons)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (..)
import Message exposing (Msg(..))
import Markdown


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

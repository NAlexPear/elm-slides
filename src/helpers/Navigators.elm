module Navigators exposing (navigate)

import Types exposing (..)
import Keyboard exposing (KeyCode)
import Array


stepForwards : Bool -> Int -> Int -> Int
stepForwards isEditing penultimate step =
    case isEditing of
        False ->
            penultimate
                |> clamp 0 (step + 1)

        True ->
            step


stepBackwards : Bool -> Int -> Int
stepBackwards isEditing step =
    case isEditing of
        False ->
            (step - 1)
                |> clamp 0 step

        True ->
            step


navigate : Model -> KeyCode -> Int
navigate model code =
    let
        step =
            model.step

        ultimate =
            Array.length model.deck.slides

        penultimate =
            ultimate - 1
    in
        case code of
            39 ->
                stepForwards model.isEditing penultimate step

            37 ->
                stepBackwards model.isEditing step

            _ ->
                step

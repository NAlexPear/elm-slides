port module Ports
    exposing
        ( authorize
        , highlight
        , clearToken
        , getToken
        , newToken
        )

import Json.Decode as Decode


port authorize : String -> Cmd msg


port highlight : String -> Cmd msg


port getToken : String -> Cmd msg


port clearToken : String -> Cmd msg


port newToken : (Decode.Value -> msg) -> Sub msg

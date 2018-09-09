module Utils.Time exposing (toMonthNumber)

import Time exposing (..)


toMonthNumber : Zone -> Posix -> Int
toMonthNumber z p =
    case toMonth z p of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12

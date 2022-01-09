module Rps.UI.Player where

import React

import Data.Int (toNumber)
import Debug (spy)
import Math (trunc)
import Prelude (max, otherwise, show, ($), (*), (/), (<>), (==), (>))
import React.DOM (int, number, td', text, tr')
import Rps.Emitters.History (Player)

type PlayerProps = {player :: Player}

playerComponent :: ReactClass PlayerProps
playerComponent = statelessComponent \{player} -> 
    tr' [
        td' [text player.name],
        td' [winRatio player],
        td' [int player.nGames],
        td' [mostPlayed player]
    ]
    where 
        winRatio :: Player -> ReactElement
        winRatio player
            | player.nGames == 0 = text "0%"
            | otherwise = text $ show (trunc (toNumber player.nWins / toNumber player.nGames * 100.0)) <> "%"
        
        -- maybe refactor this sometime, defaults to scissors in case of a tie
        mostPlayed :: Player -> ReactElement
        mostPlayed player
            | player.nRocks > max player.nPapers player.nScissors = text "Rock"
            | player.nPapers > max player.nRocks player.nScissors = text "Paper"
            | otherwise = text "Scissors"
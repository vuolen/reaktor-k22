module Rps.UI.Player where

import Data.Int (toNumber)
import Math (trunc)
import Prelude (max, otherwise, show, ($), (*), (/), (<>), (==), (>))
import RPS.UI.PlayedGame (playedGameComponent)
import React (ReactClass, ReactElement, createLeafElement, statelessComponent)
import React.DOM (b', br', div, div', int, span, span', text)
import React.DOM.Props (className, key)
import Rps.Emitters.History (Player)

type PlayerProps = {player :: Player}

playerComponent :: ReactClass PlayerProps
playerComponent = statelessComponent \{player} -> 
    div [key player.name, className "player"] $ [
        div [className "player-header"] [
            span [className "player-header-cell"] [b' [text "Name"], br', text player.name],
            span [className "player-header-cell"] [b' [text "Win ratio"], br', winRatio player],
            span [className "player-header-cell"] [b' [text "Games played"], br', int player.nGames],
            span [className "player-header-cell"] [b' [text "Most played hand"], br', mostPlayed player]
        ]
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

        createPlayedGame game = createLeafElement playedGameComponent {game}
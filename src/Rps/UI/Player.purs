module Rps.UI.Player where

import Data.Int (toNumber)
import Math (trunc)
import Prelude (map, max, otherwise, show, ($), (*), (/), (<>), (==), (>))
import RPS.UI.PlayedGame (playedGameComponent)
import React (ReactClass, ReactElement, createLeafElement, fragmentWithKey, statelessComponent)
import React.DOM (b', br', div, div', int, span, span', table, table', tbody, tbody', td, td', text, th', thead', tr, tr')
import React.DOM.Dynamic (thead)
import React.DOM.Props (className, colSpan, key)
import Rps.Emitters.History (Player)

type PlayerProps = {player :: Player}

playerComponent :: ReactClass PlayerProps
playerComponent = statelessComponent \{player} -> 
    fragmentWithKey player.name [
        tr [className "player"] [
            td [colSpan 2] [text player.name],
            td' [winRatio player],
            td' [int player.nGames],
            td' [mostPlayed player]
        ],
        tr [className "playedGames"] [
            td [colSpan 4] [
                table' [
                    thead' [
                        tr' [
                            th' [text "Finished"],
                            th' [text "Player A"],
                            th' [text "Player B"],
                            th' [text "Winner"]
                        ]
                    ],
                    tbody' $ map createPlayedGame player.games
                ]
            ]
            
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
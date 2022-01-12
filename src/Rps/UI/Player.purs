module Rps.UI.Player (
    playerComponent
) where

import Data.Int (toNumber)
import Effect (Effect)
import Math (trunc)
import Prelude (bind, map, max, not, otherwise, pure, show, ($), (*), (/), (<$>), (<>), (==), (>))
import RPS.UI.PlayedGame (playedGameComponent)
import React (ReactClass, ReactElement, ReactThis, component, createLeafElement, fragmentWithKey, getProps, getState, setState)
import React.DOM (div', int, table', tbody', td, td', text, th', thead', tr, tr')
import React.DOM.Props (className, colSpan, hidden, onClick)
import Rps.Emitters.History (Player)

type PlayerProps = {player :: Player}
type PlayerState = {collapsed :: Boolean}

playerComponent :: ReactClass PlayerProps
playerComponent = component "Player" \this -> 
    pure {
        state: {
            collapsed: true
        },
        render: render this
    }

render :: ReactThis PlayerProps PlayerState -> Effect ReactElement
render this = do
    {player} <- getProps this
    {collapsed} <- getState this
    pure $ fragmentWithKey player.name [
        tr [
            className "player",
            onClick \_ -> do
                setState this {collapsed: not collapsed}
        ] [
            td' [text player.name],
            td' [winRatio player],
            td' [int player.nGames],
            td' [mostPlayed player]
        ],
        if not collapsed then 
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
        else div' []
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
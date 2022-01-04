module Rps.UI.PlayedGame where

import React

import Prelude (($), (<>))
import React.DOM (div', h2', text)
import Rps.Types (PlayedGame)

type PlayedGameProps = {game :: PlayedGame}

playedGame :: ReactClass PlayedGameProps
playedGame = statelessComponent \{game} -> 
    div' [
        h2' [text $ game.playerA.name <> " vs. " <> game.playerB.name]
    ]
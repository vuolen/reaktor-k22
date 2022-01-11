module RPS.UI.PlayedGame where

import Prelude (($))
import React (ReactClass, statelessComponent)
import React.DOM (text, tr')
import Rps.Types (PlayedGame)
  
type PlayedGameProps = {game :: PlayedGame}

playedGameComponent :: ReactClass PlayedGameProps
playedGameComponent = statelessComponent \{game} ->
    tr' [
        text $ "Played Game"
    ]
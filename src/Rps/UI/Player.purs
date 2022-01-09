module Rps.UI.Player where

import React

import React.DOM (int, td', text, tr')
import Rps.Emitters.History (Player)

type PlayerProps = {player :: Player}

playerComponent :: ReactClass PlayerProps
playerComponent = statelessComponent \{player} -> 
    tr' [
        td' [text player.name],
        td' [int player.nGames]
    ]
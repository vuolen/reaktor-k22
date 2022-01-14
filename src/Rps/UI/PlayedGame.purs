module RPS.UI.PlayedGame where

import Prelude (show, ($), (<>))
import React (ReactClass, statelessComponent)
import React.DOM (int, number, td, td', text, tr')
import Rps.Types (PlayedGame)
import Rps.Util (isWin)

type PlayedGameProps = { game :: PlayedGame }

playedGameComponent :: ReactClass PlayedGameProps
playedGameComponent = statelessComponent \{ game } ->
  tr'
    [ td' [ text $ toLocaleString game.t ]
    , td' [ text $ game.playerA.name <> " (" <> show game.playerA.played <> ")" ]
    , td' [ text $ game.playerB.name <> " (" <> show game.playerB.played <> ")" ]
    , td' [ text $ if isWin game.playerA.played game.playerB.played then game.playerA.name else game.playerB.name ]
    ]

foreign import toLocaleString :: Number -> String
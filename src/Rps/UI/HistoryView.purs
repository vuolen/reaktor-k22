module Rps.UI.HistoryView where

import React

import Foreign.Object (Object, size)
import Prelude (show, ($), (<>))
import React.DOM (div')
import React.DOM.Dynamic (text)
import Rps.Types (PlayedGame, GameId)
import Rps.UI.PlayedGame (playedGame)

type HistoryViewProps = {history :: Object (Array PlayedGame)}

historyView :: ReactClass HistoryViewProps
historyView = statelessComponent \{history} ->
    div' [
        text $ "Fetched " <> show (size history) <> " players."
    ]
    where createPlayedGame game = createLeafElement playedGame {game}
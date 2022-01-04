module Rps.UI.App where

import React

import Data.HashMap (HashMap)
import Foreign.Object (Object)
import React.DOM (div')
import Rps.Types (LiveGame, PlayedGame, GameId)
import Rps.UI.HistoryView (historyView)
import Rps.UI.LiveView (liveView)

type AppProps = {liveGames :: Array LiveGame, history :: Object (Array PlayedGame)}

app :: ReactClass AppProps
app = statelessComponent \{liveGames, history} ->
    div' [
        createLeafElement liveView {liveGames},
        createLeafElement historyView {history}
    ]
module Rps.UI.App where

import React

import React.DOM (div')
import Rps.Emitters.History (History)
import Rps.Types (LiveGame)
import Rps.UI.HistoryView (historyView)
import Rps.UI.LiveView (liveView)

type AppProps = {liveGames :: Array LiveGame, history :: History}

app :: ReactClass AppProps
app = statelessComponent \{liveGames, history} ->
    div' [
        createLeafElement liveView {liveGames},
        createLeafElement historyView {history}
    ]
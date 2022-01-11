module Rps.UI.HistoryView where

import React

import Foreign.Object (values)
import Prelude (map, ($), (<>))
import React.DOM (div, div', h1', h2', text)
import React.DOM.Props (className)
import Rps.Emitters.History (History)
import Rps.UI.Player (playerComponent)

type HistoryViewProps = {history :: History}

historyView :: ReactClass HistoryViewProps
historyView = statelessComponent \{history} ->
    div [className "history"] $ [
        h1' [text "History"]
    ] <> (map createPlayer $ values history)
    where createPlayer player = createLeafElement playerComponent {player}
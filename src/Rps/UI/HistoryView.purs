module Rps.UI.HistoryView where

import React

import Foreign.Object (values)
import Prelude (map, ($))
import React.DOM (table', tbody', td', text, thead', tr')
import Rps.Emitters.History (History)
import Rps.UI.Player (playerComponent)

type HistoryViewProps = {history :: History}

historyView :: ReactClass HistoryViewProps
historyView = statelessComponent \{history} ->
    table' $ [
        thead' [
            tr' [
                td' [text "Name"],
                td' [text "Games played"]
            ]
        ],
        tbody' $ map createPlayer $ values history
    ]
    where createPlayer player = createLeafElement playerComponent {key: player.name, player}
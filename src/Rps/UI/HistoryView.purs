module Rps.UI.HistoryView where

import React
import Foreign.Object (values)
import Prelude (map, ($), (<>))
import React.DOM (div, div', h1', h2', table', tbody', text, th, th', thead', tr')
import React.DOM.Props (className, colSpan)
import Rps.Emitters.History (History)
import Rps.UI.Player (playerComponent)

type HistoryViewProps = { history :: History }

historyView :: ReactClass HistoryViewProps
historyView =
  statelessComponent \{ history } ->
    div [ className "history" ]
      $
        [ h1' [ text "History" ]
        , table'
            $
              [ thead'
                  [ tr'
                      [ th' [ text "Name" ]
                      , th' [ text "Win ratio" ]
                      , th' [ text "Games played" ]
                      , th' [ text "Most played hand" ]
                      ]
                  ]
              , tbody' $ map createPlayer $ values history
              ]
        ]
  where
  createPlayer player = createLeafElement playerComponent { player }

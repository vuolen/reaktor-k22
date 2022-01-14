module Rps.UI.HistoryView where

import React

import Data.Array (sortWith)
import Foreign.Object (values)
import Prelude (map, ($))
import React.DOM (div, h1', hr', table, tbody', text, th', thead', tr')
import React.DOM.Props (className)
import Rps.Emitters.History (History)
import Rps.UI.Player (playerComponent)

type HistoryViewProps = { history :: History }

historyView :: ReactClass HistoryViewProps
historyView =
  statelessComponent \{ history } ->
    createElement fragment {}
      [ h1' [ text "History" ]
      , hr'
      , div [ className "history" ]
          [ table [ className "historyTable" ]
              $
                [ thead'
                    [ tr'
                        [ th' [ text "Name" ]
                        , th' [ text "Win ratio" ]
                        , th' [ text "Games played" ]
                        , th' [ text "Most played hand" ]
                        ]
                    ]
                , tbody' $ map createPlayer $ sortWith (_.name) $ values history
                ]
          ]
      ]
  where
  createPlayer player = createLeafElement playerComponent { player }

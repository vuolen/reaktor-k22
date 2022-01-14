module Rps.UI.PlayedGameTable
  ( playedGameTableComponent
  ) where

import Data.Array (length, take)
import Effect (Effect)
import Prelude (bind, map, min, pure, show, ($), (+), (<), (<>))
import RPS.UI.PlayedGame (playedGameComponent)
import React (ReactClass, ReactElement, ReactThis, component, createLeafElement, getProps, getState, setState)
import React.DOM (button, table, table', tbody', td, text, tfoot', th', thead', tr')
import React.DOM.Props (_type, className, colSpan, onClick)
import Rps.Types (PlayedGame)
import Rps.Util (emptyElement)

type PlayedGameTableProps = { playedGames :: Array PlayedGame }
type PlayedGameTableState =
  { rowsToDisplay :: Int
  }

playedGameTableComponent :: ReactClass PlayedGameTableProps
playedGameTableComponent = component "PlayedGameTable" \this -> do
  pure
    { state:
        { rowsToDisplay: 10
        }
    , render: render this
    }

render :: ReactThis PlayedGameTableProps PlayedGameTableState -> Effect ReactElement
render this = do
  { playedGames } <- getProps this
  { rowsToDisplay } <- getState this
  pure $ table [className "playedGamesTable"]
    [ thead'
        [ tr'
            [ th' [ text "Finished" ]
            , th' [ text "Player A" ]
            , th' [ text "Player B" ]
            , th' [ text "Winner" ]
            ]
        ]
    , tbody' $ map (\game -> createLeafElement playedGameComponent { game }) (take rowsToDisplay playedGames)
    , tfoot'
        [ if rowsToDisplay < (length playedGames) then
            tr'
              [ td [ colSpan 4 ]
                  [ button
                      [ _type "button"
                      , onClick \_ -> do setState this { rowsToDisplay: min (rowsToDisplay + 10) (length playedGames) }
                      ]
                      [ text $ "Load more (" <> show rowsToDisplay <> "/" <> show (length playedGames) <> ")" ]
                  ]
              ]
          else emptyElement
        ]
    ]
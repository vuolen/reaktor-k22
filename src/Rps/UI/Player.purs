module Rps.UI.Player
  ( playerComponent
  ) where

import Data.Int (toNumber)
import Effect (Effect)
import Math (trunc)
import Prelude (bind, max, not, otherwise, pure, show, ($), (*), (/), (<>), (==), (>))
import React (ReactClass, ReactElement, ReactThis, component, createLeafElement, fragmentWithKey, getProps, getState, setState)
import React.DOM (int, td, td', text, tr, span)
import React.DOM.Props (className, colSpan, onClick)
import Rps.Emitters.History (Player)
import Rps.UI.PlayedGameTable (playedGameTableComponent)
import Rps.Util (emptyElement)

type PlayerProps = { player :: Player }

type PlayerState = { collapsed :: Boolean }

playerComponent :: ReactClass PlayerProps
playerComponent =
  component "Player" \this ->
    pure
      { state: { collapsed: true }
      , render: render this
      }

render :: ReactThis PlayerProps PlayerState -> Effect ReactElement
render this = do
  { player } <- getProps this
  { collapsed } <- getState this
  pure
    let
      toggleCollapsed = \_ -> do setState this { collapsed: not collapsed }

      aggregateDataRow =
        tr [ className "aggregateRow", onClick toggleCollapsed ]
          [ td' [ collapsibleIcon collapsed, text player.name ]
          , td' [ winRatio player ]
          , td' [ int player.nGames ]
          , td' [ mostPlayed player ]
          ]

      playedGamesTableRow =
        tr [ className "playedGamesRow" ]
          [ td [ colSpan 5, className "playedGameCell" ]
              [ createLeafElement playedGameTableComponent { playedGames: player.games } ]
          ]
    in
      fragmentWithKey player.name
        [ aggregateDataRow
        , if not collapsed then playedGamesTableRow else emptyElement
        ]
  where
  winRatio :: Player -> ReactElement
  winRatio player
    | player.nGames == 0 = text "0%"
    | otherwise = text $ show (trunc (toNumber player.nWins / toNumber player.nGames * 100.0)) <> "%"

  mostPlayed :: Player -> ReactElement
  mostPlayed player
    | player.nRocks > max player.nPapers player.nScissors = text "Rock"
    | player.nPapers > max player.nRocks player.nScissors = text "Paper"
    | otherwise = text "Scissors"

  collapsibleIcon :: Boolean -> ReactElement
  collapsibleIcon collapsed = span [className "collapsibleIcon"] [
    text $ if collapsed then "+" else "-"
  ]

module Rps.UI.LiveGame where

import React

import Data.Functor ((<$>))
import Data.Maybe (Maybe(..), fromMaybe)
import Prelude (map, show, ($), (<>))
import React.DOM (b', br', div, div', h2', text)
import React.DOM.Props (className)
import Rps.Types (LiveGame(..), PlayedGame, RPS(..))

type LiveGameProps = { game :: LiveGame }

liveGame :: ReactClass LiveGameProps
liveGame = statelessComponent \{ game } -> liveGame' game
  where
  liveGame' (InProgress game) = div [ className "liveGame" ]
    [ b' [ text $ game.playerA.name <> " vs. " <> game.playerB.name ]
    , br'
    , text $ "In progress..."
    ]
  liveGame' (Finished game) = div [ className "liveGame" ]
    [ b' [ text $ game.playerA.name <> " vs. " <> game.playerB.name ]
    , br'
    , text $ show game.playerA.played <> " vs. " <> show game.playerB.played
    , br'
    , text $ fromMaybe "Its a tie!" $ (_ <> " wins!") <$> (_.name) <$> (winner game)
    ]

  winner :: PlayedGame -> Maybe { name :: String, played :: RPS }
  winner { playerA, playerB } = case map _.played [ playerA, playerB ] of
    [ Rock, Scissors ] -> Just playerA
    [ Paper, Rock ] -> Just playerA
    [ Scissors, Paper ] -> Just playerA
    [ Scissors, Rock ] -> Just playerB
    [ Rock, Paper ] -> Just playerB
    [ Paper, Scissors ] -> Just playerB
    _ -> Nothing

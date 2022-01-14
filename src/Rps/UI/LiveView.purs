module Rps.UI.LiveView where

import React

import Prelude (map, ($))
import React.DOM (div)
import React.DOM.Props (className)
import Rps.Types (LiveGame)
import Rps.UI.LiveGame (liveGame)

type LiveViewProps = { liveGames :: Array LiveGame }

liveView :: ReactClass LiveViewProps
liveView = statelessComponent \{ liveGames } ->
  div [ className "live" ] $ map createLiveGame liveGames
  where
  createLiveGame game = createLeafElement liveGame { game }
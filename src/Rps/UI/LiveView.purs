module Rps.UI.LiveView where

import Prelude (map, ($))
import React
import React.DOM (div')
import Rps.Types (LiveGame)
import Rps.UI.LiveGame (liveGame)

type LiveViewProps = {liveGames :: Array LiveGame}

liveView :: ReactClass LiveViewProps
liveView = statelessComponent \{liveGames} ->
    div' $ map createLiveGame liveGames
    where createLiveGame game = createLeafElement liveGame {game}
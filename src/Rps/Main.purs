module Rps.Main where

import Prelude

import Data.Tuple (Tuple(..))
import Effect (Effect)
import Halogen.Subscription (subscribe)
import Rps.Emitters.History as History
import Rps.Emitters.LiveGames as LiveGames
import Rps.UI as UI

main :: Effect Unit
main = do
  let props = Tuple <$> LiveGames.liveGamesEmitter <*> History.historyEmitter

  void $ subscribe props \(Tuple liveGames history) -> do
    UI.renderApp { liveGames, history }
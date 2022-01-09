module Rps.Util where

import Halogen.Subscription (Emitter, makeEmitter, subscribe, unsubscribe)
import Prelude (bind, discard, pure, ($))
import Rps.Types (RPS(..))

-- Creates an emitter that immediately emits first, then the other emitters values
withFirst :: forall a. a -> Emitter a -> Emitter a
withFirst first e = makeEmitter \cb -> do
    cb first
    sub <- subscribe e cb
    pure $ unsubscribe sub

-- returns true if the first hand is the winner
isWin :: RPS -> RPS -> Boolean
isWin Rock Scissors = true 
isWin Scissors Paper = true
isWin Paper Rock = true
isWin _ _ = false
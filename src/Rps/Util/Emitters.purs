module Rps.Util.Emitters where

import Halogen.Subscription (Emitter, makeEmitter, subscribe, unsubscribe)
import Prelude (bind, discard, pure, ($))

-- Creates an emitter that immediately emits first, then the other emitters values
withFirst :: forall a. a -> Emitter a -> Emitter a
withFirst first e = makeEmitter \cb -> do
    cb first
    sub <- subscribe e cb
    pure $ unsubscribe sub

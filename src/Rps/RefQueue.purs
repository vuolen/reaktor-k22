module RefQueue where

import Prelude

import Data.Array (snoc, head)
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect.Ref as Ref
  
type RefQueue a = Ref.Ref (Array a)

new :: forall a. Effect (RefQueue a)
new = Ref.new []

put :: forall a. RefQueue a -> a -> Effect Unit
put refQueue x = Ref.modify_ (\old -> snoc old x) refQueue

take :: forall a. RefQueue a -> Effect (Maybe a)
take = map head <<< Ref.read
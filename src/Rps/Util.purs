module Rps.Util where

import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.Time (Time, diff)
import Data.Time.Duration (Milliseconds)
import Effect (Effect)
import Effect.Now (nowTime)
import Effect.Ref as Ref
import Halogen.Subscription (Emitter, makeEmitter, subscribe, unsubscribe)
import Prelude (Unit, bind, discard, pure, unit, ($), (>))
import React (ReactElement, createElement, fragment)
import Rps.Types (RPS(..))

-- Creates an emitter that immediately emits first, then the other emitters values
withFirst :: forall a. a -> Emitter a -> Emitter a
withFirst first e = makeEmitter \cb -> do
  cb first
  sub <- subscribe e cb
  pure $ unsubscribe sub

-- if the emitter emits faster then the duration, the values get discarded
throttle :: forall a. Number -> Emitter a -> Emitter a
throttle duration e = makeEmitter \cb -> do
  lastEmit <- Ref.new Nothing
  sub <- subscribe e \a -> do
    last <- Ref.read lastEmit
    case last of
      Just lastTime -> do
        now <- nowTime
        let
          milliseconds = diff now lastTime :: Milliseconds
          elapsed = unwrap milliseconds
        if elapsed > duration then emit lastEmit cb a else pure unit
      Nothing -> emit lastEmit cb a
  pure $ unsubscribe sub
  where
  emit :: Ref.Ref (Maybe Time) -> (a -> Effect Unit) -> a -> Effect Unit
  emit ref cb a = do
    cb a
    now <- nowTime
    Ref.write (Just now) ref

-- returns true if the first hand is the winner
isWin :: RPS -> RPS -> Boolean
isWin Rock Scissors = true
isWin Scissors Paper = true
isWin Paper Rock = true
isWin _ _ = false

emptyElement :: ReactElement
emptyElement = createElement fragment {} []
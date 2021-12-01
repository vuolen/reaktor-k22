module Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Console (log)
import API (getFullHistory)

main :: Effect Unit
main = launchAff_ getFullHistory

module Rps.Types where

import Prelude

import Data.Argonaut (class DecodeJson, JsonDecodeError(..), decodeJson)
import Data.Either (Either(..))

data WSEvent = GameBegin NewGame | GameResult PlayedGame

data RPS = Rock | Paper | Scissors

instance rpsDecodeJson :: DecodeJson RPS where
  decodeJson json = do
    str <- decodeJson json
    case str of
      "ROCK" -> Right Rock
      "PAPER" -> Right Paper
      "SCISSORS" -> Right Scissors
      _ -> Left (TypeMismatch "Play")

instance showRPS :: Show RPS where
  show Rock = "Rock"
  show Paper = "Paper"
  show Scissors = "Scissors"

derive instance eqRPS :: Eq RPS

data LiveGame = InProgress NewGame | Finished PlayedGame

instance showLiveGame :: Show LiveGame where
  show (InProgress newGame) = show newGame
  show (Finished playedGame) = show playedGame

type GameId = String

type NewGame =
  { gameId :: GameId
  , playerA ::
      { name :: String
      }
  , playerB ::
      { name :: String
      }
  }

type PlayedGame =
  { gameId :: String
  , t :: Number
  , playerA ::
      { name :: String
      , played :: RPS
      }
  , playerB ::
      { name :: String
      , played :: RPS
      }
  }

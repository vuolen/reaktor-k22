module Rps.Types where

import Prelude

import Control.Monad.Except (ExceptT)
import Control.Monad.State (StateT)
import Data.Argonaut (class DecodeJson, JsonDecodeError(..), decodeJson)
import Data.Either (Either(..))
import Data.HashMap (HashMap)
import Effect.Aff (Aff)
import Effect.Exception (Error)
import Halogen.Subscription (Listener)

data RpsEvent = Initialize | Render

data WSEvent = GameBegin NewGame | GameResult PlayedGame

data LiveGame = InProgress NewGame | Finished PlayedGame
instance showLiveGame :: Show LiveGame where
  show (InProgress newGame) = show newGame
  show (Finished playedGame) = show playedGame

type RpsMonad = StateT RpsState (ExceptT Error Aff) 

type RpsState = {
    playedGames :: HashMap String (Array PlayedGame),
    liveGames :: Array NewGame,
    listener :: Listener RpsEvent
}

data RPS = Rock | Paper | Scissors
instance rpsDecodeJson :: DecodeJson RPS where
    decodeJson json = do
        str <-  decodeJson json
        case str of
            "ROCK" -> Right Rock
            "PAPER" -> Right Paper
            "SCISSORS" -> Right Scissors
            _ -> Left (TypeMismatch "Play")

instance showRPS :: Show RPS where
  show Rock = "Rock"
  show Paper = "Paper"
  show Scissors = "Scissors"
  
type GameId = String

type NewGame = {
    gameId :: GameId,
    playerA :: {
        name :: String
    },
    playerB :: {
        name :: String
    }
}

type PlayedGame = {
        gameId :: String,
        t :: Number,
        playerA :: {
            name :: String,
            played :: RPS
        },
        playerB :: {
            name :: String,
            played :: RPS
        }
}
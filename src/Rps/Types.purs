module Rps.Types where

import Control.Monad.Except (ExceptT)
import Control.Monad.State (StateT)
import Data.HashMap (HashMap)
import Effect.AVar (AVar)
import Effect.Aff (Aff)
import Effect.Exception (Error)
import RefQueue (RefQueue)

type RpsMonad = StateT RpsState (ExceptT Error Aff) 

type RpsState = {
    playedGames :: HashMap String (Array PlayedGame),
    liveGames :: Array NewGame,
    messages :: AVar WebSocketMessage
}

data WebSocketMessage = GameBegin NewGame | GameResult PlayedGame
  
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
            played :: String
        },
        playerB :: {
            name :: String,
            played :: String
        }
}
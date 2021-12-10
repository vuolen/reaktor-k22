module Rps.Main where

import Prelude

import Control.Monad.Except (lift, runExceptT, throwError)
import Control.Monad.State (get, gets, modify_, put, runStateT)
import Data.Argonaut ((.!=))
import Data.Array (filter, foldr, (:))
import Data.Either (Either(..))
import Data.HashMap (HashMap, empty, insert, insertWith)
import Data.Lazy (Lazy, defer)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple, snd)
import Data.Tuple.Nested ((/\))
import Debug (spy)
import Effect (Effect)
import Effect.AVar as AVar
import Effect.Aff (Aff, Fiber, joinFiber, launchAff, launchAff_, runAff)
import Effect.Class (liftEffect)
import Effect.Class.Console (errorShow, logShow)
import Effect.Console (error, log)
import Effect.Exception (Error, throw)
import Effect.Timer (setTimeout)
import Effect.Uncurried (EffectFn1)
import RefQueue as RQ
import Rps.API (HistoryResponse, apiGetJson)
import Rps.Types (NewGame, PlayedGame, RpsMonad, WebSocketMessage(..), RpsState)
import Rps.WS as WS


type Props = {
    liveGames :: Array NewGame
}

foreign import render :: Props -> Effect Unit

runRpsMonad :: forall a. RpsMonad a -> RpsState -> Aff (Either Error (Tuple a RpsState))
runRpsMonad monad state = runExceptT $ runStateT monad state

main :: Effect Unit 
main = do
    messages <- AVar.empty
    let initialState = {
        playedGames: empty,
        liveGames: [],
        messages
    }
    void $ runAff (
        \e -> case e of
            Right (Right (_ /\ state)) -> loop state
            Right (Left err) -> throwError err
            Left err -> throwError err
    ) $ runRpsMonad (do WS.connect) initialState

    where 
        loop :: RpsState -> Effect Unit
        loop state = do
          void $ runAff (
            \e -> case e of
                Right (Right (_ /\ newState)) -> void $ setTimeout 1000 (loop newState)
                Right (Left err) -> throwError err
                Left err -> throwError err
          ) $ runRpsMonad app state

app :: RpsMonad Unit
app = do
    liftEffect $ log "app"
    messages <- gets _.messages
    maybeMessage <- liftEffect $ AVar.tryTake messages
    case maybeMessage of
        Just msg -> case msg of
            GameBegin newGame -> modify_ \state -> state {
                liveGames = newGame : state.liveGames
            }
            GameResult playedGame -> modify_ \state -> state {
                liveGames = filter (\liveGame -> liveGame.gameId == playedGame.gameId) state.liveGames,
                playedGames = insertWith (<>) playedGame.playerA.name [playedGame] $ insertWith (<>) playedGame.playerB.name [playedGame] state.playedGames
            }
        Nothing -> pure unit
    liveGames <- gets _.liveGames
    liftEffect $ render {
        liveGames
    }

data Recur = Next (Lazy (RpsMonad Recur)) | End

getPage :: String -> RpsMonad Recur
getPage path = do
        state <- get
        page :: HistoryResponse <- lift $ apiGetJson path
        put $ state {
            playedGames = updatePlayedGames state.playedGames (spy "data" page.data) 
        }
        case page.cursor of
            Just c -> pure $ Next $ defer \_ -> getPage c
            Nothing -> pure $ End
    where
        updatePlayedGames :: HashMap String (Array PlayedGame) -> Array PlayedGame -> HashMap String (Array PlayedGame)
        updatePlayedGames playedGames newGames = foldr (\game acc -> insertWith (<>) game.playerA.name [game] acc) playedGames newGames
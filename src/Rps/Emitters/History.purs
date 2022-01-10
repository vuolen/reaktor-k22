module Rps.Emitters.History (
    historyEmitter,
    History,
    Player
) where

import Prelude

import Control.Monad.ST (ST)
import Data.Array (foldr, (:))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Aff (Aff, Error, Milliseconds(..), delay, error, killFiber, runAff, runAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Foreign.Object (Object, empty, runST, thawST)
import Foreign.Object.ST (STObject, peek, poke)
import Halogen.Subscription (Emitter, fold, makeEmitter, subscribe, unsubscribe)
import Rps.API (HistoryResponse, apiGetJson)
import Rps.Emitters.WS as WS
import Rps.Types (RPS(..), WSEvent(..), PlayedGame)
import Rps.Util (isWin, withFirst)

historyEmitter :: Emitter History
historyEmitter = withFirst empty $ fold (\page history -> runST (foldr addGameToHistory (thawST history) page)) playedGamesEmitter empty
        
-- emits an array for efficiency. When a page gets fetched theres ~600 games and updating the history one by one is a bit slow
playedGamesEmitter :: Emitter (Array PlayedGame)
playedGamesEmitter = makeEmitter \cb -> do
    sub1 <- subscribe pagesEmitter (cb <<< _.data)
    sub2 <- subscribe WS.connectWS (case _ of
        (GameResult playedGame) -> cb [playedGame]
        _ -> pure unit)
    pure $ traverse_ unsubscribe [sub1, sub2]

pagesEmitter :: Emitter HistoryResponse
pagesEmitter = makeEmitter \cb -> do
    fiber <- runAff (\e -> case e of
                Left err -> Console.error $ show err
                -- TODO: CHOOSE CORRECTLY WHEN FINISHED, avoids a lot of requests when debugging
                --Right _ -> pure unit) $ getPages "/rps/history?cursor=3ecMyZ0t7AAo" cb
                Right _ -> pure unit) $ getPages "/rps/history?cursor=-sz1vUtyeKGl" cb 
                --Right _ -> pure unit) $ getPages "/rps/history" cb
    pure $ runAff_ (\e -> case e of
                        Left err -> Console.error $ "Failed to kill fiber.. what now"
                        Right _ -> Console.log $ "Killed pagesEmitter succesfully") $ killFiber (error "pagesEmitter unsubscribed") fiber
    where
        getPages :: String -> (HistoryResponse -> Effect Unit) -> Aff Unit
        getPages path callback = do
            page :: Either Error HistoryResponse <- apiGetJson path
            case page of
                Right response -> case response.cursor of
                    Just c -> do
                        liftEffect $ callback response
                        getPages c callback
                    Nothing -> pure unit
                Left err -> do
                    liftEffect $ Console.error $ "Failed to fetch page " <> path <> " - Trying again in 3 seconds" 
                    delay (Milliseconds 3000.0)
                    getPages path callback
    
type History = Object Player

type Player = {
    name :: String,
    nGames :: Int,
    nWins :: Int,
    nRocks :: Int,
    nPapers :: Int,
    nScissors :: Int,
    games :: Array PlayedGame
}

-- This state manipulation increased fps from around 50 to 90 for me (on a desktop)

type STHistory r = ST r (STObject r Player)

addGameToHistory :: forall r. PlayedGame -> STHistory r -> STHistory r
addGameToHistory game historyST = do
    foldr (\player oldHistoryST -> do
            oldHistory <- oldHistoryST
            maybeExistingPlayer <- peek player.name oldHistory
            case maybeExistingPlayer of
                Just existingPlayer -> poke existingPlayer.name (addGameToPlayer game existingPlayer) oldHistory
                Nothing -> poke player.name (addGameToPlayer game (newPlayer player.name)) oldHistory
    ) historyST [game.playerA, game.playerB]

    where
        addGameToPlayer :: PlayedGame -> Player -> Player
        addGameToPlayer game player = player {
            nGames = player.nGames + 1,
            nWins = if isWin playerPlayed opponentPlayed then player.nWins + 1 else player.nWins,
            nRocks = incrementIfPlayed Rock player.nRocks,
            nPapers = incrementIfPlayed Paper player.nPapers,
            nScissors = incrementIfPlayed Scissors player.nScissors,
            games = game : player.games
        }
            where
                {playerPlayed, opponentPlayed} = 
                            if game.playerA.name == player.name then
                                {playerPlayed: game.playerA.played, opponentPlayed: game.playerB.played}
                            else
                                {opponentPlayed: game.playerA.played, playerPlayed: game.playerB.played}

                incrementIfPlayed :: RPS -> Int -> Int
                incrementIfPlayed rps n = if playerPlayed == rps then n + 1 else n


        newPlayer :: String -> Player
        newPlayer name = {
            name,
            nGames: 0,
            nWins: 0,
            nRocks: 0,
            nPapers: 0,
            nScissors: 0,
            games: []
        }
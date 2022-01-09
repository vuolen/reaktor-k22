module Rps.Emitters.History (
    historyEmitter,
    History,
    Player
) where

import Prelude

import Data.Array (foldr, (:))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Debug (spy)
import Effect (Effect)
import Effect.Aff (Aff, Error, Milliseconds(..), delay, error, killFiber, runAff, runAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Foreign.Object (Object, empty, insert, lookup)
import Halogen.Subscription (Emitter, fold, makeEmitter)
import Rps.API (HistoryResponse, apiGetJson)
import Rps.Types (PlayedGame, RPS(..))
import Rps.Util (isWin, withFirst)

historyEmitter :: Emitter History
historyEmitter = withFirst empty $ fold (\page history -> foldr addGameToHistory history page.data) pagesEmitter empty
        

pagesEmitter :: Emitter HistoryResponse
pagesEmitter = makeEmitter \cb -> do
    fiber <- runAff (\e -> case e of
                Left err -> Console.error $ show err
                -- TODO: CHOOSE CORRECTLY WHEN FINISHED, avoids a lot of requests when debugging
                --Right _ -> pure unit) $ getPages "/rps/history?cursor=3ecMyZ0t7AAo" cb
                Right _ -> pure unit) $ getPages "/rps/history" cb
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

addGameToHistory :: PlayedGame -> History -> History
addGameToHistory game history = foldr (
        \player oldHistory -> case lookup player.name oldHistory of
            Just player -> insert player.name (addGameToPlayer game player) oldHistory
            Nothing -> insert player.name (addGameToPlayer game (newPlayer player.name)) oldHistory
    ) history [game.playerA, game.playerB]

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
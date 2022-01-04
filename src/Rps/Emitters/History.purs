module Rps.Emitters.History where

import Prelude

import Data.Array (uncons, (:))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, Error, Milliseconds(..), delay, runAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error)
import Foreign.Object (Object, empty, fromFoldableWith, union)
import Halogen.Subscription (Emitter, Listener, create, fold, notify)
import Rps.API (HistoryResponse, apiGetJson)
import Rps.Types (PlayedGame, GameId)

historyEmitter :: Effect (Emitter (Object (Array PlayedGame)))
historyEmitter = do
    {emitter, listener} <- create
    runAff_ (\e -> case e of
                Left err -> error $ show err
                Right _ -> pure unit) $ getPages "/rps/history" listener
    pure $ fold (\page history -> 
        let 
            createKeyValues :: Array PlayedGame -> Array (Tuple GameId (Array PlayedGame)) -> Array (Tuple GameId (Array PlayedGame))
            createKeyValues games keyValues = case uncons games of
                Just {head: game, tail: rest} -> (Tuple game.playerA.name [game]) : (Tuple game.playerB.name [game]) : (createKeyValues rest keyValues)
                Nothing -> keyValues
            newMap = fromFoldableWith (<>) $ createKeyValues page.data []
        in union history newMap
        ) emitter empty
    where
        getPages :: String -> Listener HistoryResponse -> Aff Unit
        getPages path listener = do
            page :: Either Error HistoryResponse <- apiGetJson path
            case page of
                Right response -> case response.cursor of
                    Just c -> do
                        liftEffect $ notify listener response
                        getPages c listener
                    Nothing -> pure unit
                Left err -> do
                    liftEffect $ error $ "Failed to fetch page " <> path <> " - Trying again in 3 seconds" 
                    delay (Milliseconds 3000.0)
                    getPages path listener
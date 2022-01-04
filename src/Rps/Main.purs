module Rps.Main where

import Prelude

import Control.Monad.Except (runExceptT)
import Control.Monad.State (runStateT)
import Data.Array (uncons, (:))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay, runAff_)
import Effect.Class (liftEffect)
import Effect.Console (error)
import Effect.Exception (Error)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Effect.Timer (setTimeout)
import Foreign.Object (Object, delete, empty, fromFoldableWith, insert, union, values)
import Halogen.Subscription (Emitter, Listener, create, fold, notify, subscribe)
import Rps.API (HistoryResponse, apiGetJson)
import Rps.Emitters.LiveGames (liveGames)
import Rps.Types (GameId, LiveGame(..), RpsMonad, RpsState, WSEvent(..), PlayedGame)
import Rps.UI as UI
import Rps.WS as WS

type Props = {
    liveGames :: Array LiveGame
}

runRpsMonad :: forall a. RpsMonad a -> RpsState -> Aff (Either Error (Tuple a RpsState))
runRpsMonad monad state = runExceptT $ runStateT monad state
{- 
combine2 :: forall a b. Emitter a -> Emitter b -> Emitter (Tuple a b)
combine2 eA eB = makeEmitter \k -> do
    latestA <- Ref.new Nothing
    latestB <- Ref.new Nothing
    sub1 <- eA \a -> do
        Ref.write (Just a) latestA
        b <- Ref.read latestB
        k (Tuple a b)   
    sub2 <- eB \b -> do
        Ref.write (Just b) latestB
        a <- Ref.read latestA
        k (Tuple a b)
    pure $ unsubscribe sub1 >>= unsubscribe sub2 -}

main :: Effect Unit 
main = do
    app <- createApp
    void $ subscribe app (\_ -> pure unit)
    

createApp :: Effect (Emitter Unit)
createApp = do
    {listener, emitter} <- create
    live <- liveGames
    history <- historyPages

    let props = Tuple <$> live <*> history

    _ <- subscribe props \(Tuple liveGames history) -> do
        UI.renderApp {liveGames: [], history}
        notify listener unit
        
    pure emitter


historyPages :: Effect (Emitter (Object (Array PlayedGame)))
historyPages = do
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
module Rps.Emitters.LiveGames where

import Effect (Effect)
import Effect.Ref as Ref
import Effect.Timer (setTimeout)
import Foreign.Object (Object, delete, empty, insert, values)
import Halogen.Subscription (Emitter, create, notify, subscribe)
import Prelude (Unit, bind, pure, void, ($))
import Rps.Emitters.WS as WS
import Rps.Types (LiveGame(..), WSEvent(..))

liveGames :: Effect (Emitter (Array LiveGame))
liveGames = do
    {listener, emitter} <- create
    wsEmitter <- WS.connectWS
    liveGameMap :: Ref.Ref (Object LiveGame) <- Ref.new empty

    let
        updateLiveGames :: WSEvent -> Effect Unit
        updateLiveGames (GameBegin newGame) = modifyRefAndNotifyValues (insert newGame.gameId (InProgress newGame))
        updateLiveGames (GameResult playedGame) = do
            _ <- modifyRefAndNotifyValues (insert playedGame.gameId (Finished playedGame))
            void $ setTimeout 5000 $ do
                modifyRefAndNotifyValues (delete playedGame.gameId)
                
        modifyRefAndNotifyValues :: (Object LiveGame -> Object LiveGame) -> Effect Unit
        modifyRefAndNotifyValues fn = do
            newMap <- Ref.modify fn liveGameMap
            notify listener $ values newMap

    _ <- subscribe wsEmitter updateLiveGames
    pure $ emitter
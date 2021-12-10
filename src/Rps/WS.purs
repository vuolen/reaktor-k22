module Rps.WS where

import Prelude

import Control.Monad.Except (except)
import Control.Monad.State (get, lift)
import Data.Argonaut (Json, JsonDecodeError(..), caseJsonObject, decodeJson, fromString, getField, jsonParser, printJsonDecodeError, toString)
import Data.Either (Either(..), note)
import Effect.AVar as AVar
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Effect.Exception (Error, error, message)
import Foreign (unsafeFromForeign)
import RefQueue as RQ
import Rps.API (mapLeft)
import Rps.Types (RpsMonad, WebSocketMessage(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.Socket.Event.EventTypes (onMessage)
import Web.Socket.Event.MessageEvent (MessageEvent, data_, fromEvent)
import Web.Socket.WebSocket (create, toEventTarget)

connect :: RpsMonad Unit
connect = do
    state <- get
    ws <- liftEffect $ create "wss://bad-api-assignment.reaktor.com/rps/live" []
    let eventTarget = toEventTarget ws
    onMessageListener <- liftEffect $ eventListener (\ev -> case parseEventToMessage ev of
                                                                Right msg -> void $ AVar.put msg state.messages mempty
                                                                Left err -> Console.error $ message err)
    liftEffect $ addEventListener onMessage onMessageListener false eventTarget
 
parseEventToMessage :: Event -> Either Error WebSocketMessage
parseEventToMessage ev = do
    messageEvent <- note (error "parseEventToMessage: Failed to convert event into MessageEvent") $ fromEvent ev
    json <- getJsonFromMessageEvent messageEvent
    message <- mapLeft (error <<< printJsonDecodeError) $ caseJsonObject (Left $ TypeMismatch "Object") (
        \object -> do
            messageType <- getField object "type"
            case messageType of
                "GAME_BEGIN" -> GameBegin <$> decodeJson json
                "GAME_RESULT" -> GameResult <$> decodeJson json
                _ -> Left $ UnexpectedValue $ fromString $ messageType
    ) json
    pure message

getJsonFromMessageEvent :: MessageEvent -> Either Error Json
getJsonFromMessageEvent ev = mapLeft error do
    -- The data is encoded twice so first we have to parse it to a string and then into an object
    jsonString <- jsonParser $ unsafeFromForeign $ data_ ev
    str <- note "getJsonFromMessageEvent: Malformed JSON" $ toString jsonString
    jsonParser str

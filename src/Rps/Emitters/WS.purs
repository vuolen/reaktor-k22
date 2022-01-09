module Rps.Emitters.WS where

import Prelude

import Data.Argonaut (Json, JsonDecodeError(..), caseJsonObject, decodeJson, fromString, getField, jsonParser, printJsonDecodeError, toString)
import Data.Either (Either(..), note)
import Effect.Class.Console as Console
import Effect.Exception (Error, error, message)
import Foreign (unsafeFromForeign)
import Halogen.Subscription (makeEmitter)
import Halogen.Subscription as HS
import Rps.API (mapLeft)
import Rps.Types (WSEvent(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.Socket.Event.EventTypes (onMessage)
import Web.Socket.Event.MessageEvent (MessageEvent, data_, fromEvent)
import Web.Socket.WebSocket (close, create, toEventTarget)
  

connectWS :: HS.Emitter WSEvent
connectWS = makeEmitter \cb -> do
    ws <- create "wss://bad-api-assignment.reaktor.com/rps/live" []
    let eventTarget = toEventTarget ws
    onMessageListener <- eventListener (\ev -> case parseEventToRpsEvent ev of
                                                                Right msg -> cb msg
                                                                Left err -> Console.error $ message err)
    addEventListener onMessage onMessageListener false eventTarget
    pure $ close ws
 
parseEventToRpsEvent :: Event -> Either Error WSEvent
parseEventToRpsEvent ev = do
    messageEvent <- note (error "parseEventToMessage: Failed to convert event into MessageEvent") $ fromEvent ev
    json <- getJsonFromMessageEvent messageEvent
    mapLeft (error <<< printJsonDecodeError) $ caseJsonObject (Left $ TypeMismatch "Object") (
        \object -> do
            messageType <- getField object "type"
            case messageType of
                "GAME_BEGIN" -> GameBegin <$> decodeJson json
                "GAME_RESULT" -> GameResult <$> decodeJson json
                _ -> Left $ UnexpectedValue $ fromString $ messageType
    ) json

getJsonFromMessageEvent :: MessageEvent -> Either Error Json
getJsonFromMessageEvent ev = mapLeft error do
    -- The data is encoded twice so first we have to parse it to a string and then into an object
    jsonString <- jsonParser $ unsafeFromForeign $ data_ ev
    str <- note "getJsonFromMessageEvent: Malformed JSON" $ toString jsonString
    jsonParser str

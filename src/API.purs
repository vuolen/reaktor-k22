module API (
    getFullHistory,
    MyDateTime,
    RPS
) where

import Affjax as AX
import Affjax.ResponseFormat (json)
import Data.Argonaut (class DecodeJson, JsonDecodeError(..), decodeJson, printJsonDecodeError)
import Data.DateTime (DateTime)
import Data.DateTime.Instant (instant, toDateTime)
import Data.Either (Either(..), note)
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Seconds(..), fromDuration)
import Data.HTTP.Method (Method(..))
import Effect.Aff (Aff)
import Prelude (bind, map, pure, ($))

_API_URL = "https://bad-api-assignment.reaktor.com" :: String

data RPS = Rock | Paper | Scissors

rpsFromString :: String -> Maybe RPS
rpsFromString = case _ of
        "ROCK" -> Just Rock
        "PAPER" -> Just Paper
        "SCISSORS" -> Just Scissors
        _ -> Nothing

instance decodeJsonRPS :: DecodeJson RPS where
    decodeJson json = do
        string <- decodeJson json
        note (TypeMismatch "RPS") (rpsFromString string)

newtype MyDateTime = MyDateTime DateTime

unixEpochToMyDateTime :: Int -> Maybe MyDateTime
unixEpochToMyDateTime int = maybeMyDateTime
    where
        number = toNumber int
        seconds = Seconds number 
        milliseconds = fromDuration seconds
        maybeInstant = instant milliseconds
        maybeDateTime = map toDateTime maybeInstant
        maybeMyDateTime = map MyDateTime maybeDateTime


instance decodeJsonMyDateTime :: DecodeJson MyDateTime where
    decodeJson json = do
        int <- decodeJson json
        note (TypeMismatch "MyDateTime") (unixEpochToMyDateTime int)

type HistoryResponse = {
    gameId :: String,
    time :: MyDateTime,
    playerA :: {
        name :: String,
        played :: RPS
    },
    playerB :: {
        name :: String,
        played :: RPS
    }
}

mapLeft :: forall a b c. (a -> c) -> Either a b -> Either c b
mapLeft f (Left x) = Left $ f x
mapLeft _ (Right x) = Right x

getFullHistory :: Aff (Either String HistoryResponse)
getFullHistory = do
    page <- AX.request (AX.defaultRequest {
        url = _API_URL,
        method = Left GET,
        responseFormat = json,
        withCredentials = true
    })
    case page of
        Left err -> pure (Left $ AX.printError err)
        Right res -> pure $ mapLeft printJsonDecodeError (decodeJson res.body)
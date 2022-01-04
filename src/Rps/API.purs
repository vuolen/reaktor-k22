module Rps.API (
    apiGetJson,
    MyDateTime,
    HistoryResponse,
    mapLeft
) where

import Affjax (Request, Response)
import Affjax as AX
import Affjax.ResponseFormat (ResponseFormat(..), json)
import Control.Monad.Except (ExceptT(..), except, lift, runExceptT)
import Data.Argonaut (class DecodeJson, Json, JsonDecodeError(..), decodeJson, printJsonDecodeError, stringify)
import Data.DateTime (DateTime)
import Data.DateTime.Instant (instant, toDateTime)
import Data.Either (Either(..), note)
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Seconds(..), fromDuration)
import Debug (spy)
import Effect.Aff (Aff)
import Effect.Aff.Class (liftAff)
import Effect.Exception (Error, error)
import Prelude (class Show, bind, identity, map, pure, ($), (<$>), (<<<), (<>), (>>=))
import Rps.Types (PlayedGame)

_API_URL = "https://vuolen-cors-proxy.herokuapp.com/https://bad-api-assignment.reaktor.com" :: String

newtype MyDateTime = MyDateTime DateTime

derive newtype instance showMyDateTime :: Show MyDateTime

unixEpochToMyDateTime :: Number -> Maybe MyDateTime
unixEpochToMyDateTime num = map (MyDateTime <<< toDateTime) $ (instant <<< fromDuration <<< Seconds) num

instance decodeJsonMyDateTime :: DecodeJson MyDateTime where
    decodeJson json = do
        number <- decodeJson json
        note (TypeMismatch "MyDateTime") (unixEpochToMyDateTime number)


type HistoryResponse = {
    cursor :: Maybe String,
    data :: Array PlayedGame
}

mapLeft :: forall a b c. (a -> c) -> Either a b -> Either c b
mapLeft f (Left x) = Left $ f x
mapLeft _ (Right x) = Right x

apiGetJson :: forall a. DecodeJson a => String -> Aff (Either Error a)
apiGetJson path = do
    res <- response
    pure $ map _.body res >>= (\body -> mapLeft (error <<< printJsonDecodeError) (decodeJson body))
    where 
        response :: Aff (Either Error (Response Json))
        response = do
            res <- AX.request (AX.defaultRequest {
                url = _API_URL <> path,
                method = Left GET,
                responseFormat = json
            })
            pure $ mapLeft (error <<< AX.printError) res
module API where

import Prelude ((<>), bind, ($))
import Effect.Aff (Aff)
import Data.DateTime (DateTime)
import Data.Either (Either(..))
import Affjax as AX
import Affjax.ResponseFormat (json)
import Data.Argonaut (stringify)
import Effect.Class.Console (log)

_API_URL = "https://bad-api-assignment.reaktor.com" :: String

data RPS = Rock | Paper | Scissors

type GameResult = {
    gameId :: String,
    time :: DateTime,
    playerA :: {
        name :: String,
        played :: RPS
    },
    playerB :: {
        name :: String,
        played :: RPS
    }
}

getFullHistory :: Either Error (Aff (Array GameResult))
getFullHistory = getFullHistory_ "/rps/history" []
    where
        getFullHistory_ :: String -> Array GameResult -> Aff (Array GameResult)
        getFullHistory_ path results = do
            page <- AX.get json (_API_URL <> path)
            
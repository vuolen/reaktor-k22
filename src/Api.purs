module API where

import Prelude ((<>))
import Effect.Aff (Aff)
import Data.DateTime (DateTime)
import Affjax as AX
import Affjax.ResponseFormat (json)
import Effect.Class.Console (log)

_API_URL = "https://bad-api-assignment.reaktor.com"

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

getFullHistory :: Aff (Array GameResult) 
getFullHistory = getFullHistory_ "/rps/history" []
    where
        getFullHistory_ path results = do
            page <- AX.get json (_API_URL <> path)
            case page of
                Left err -> log $ "GET " <> path <> " failed: " <> AX.printError err 
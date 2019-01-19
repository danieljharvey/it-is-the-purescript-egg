module Egg.Dom.Loader where

import Prelude

import Effect (Effect)
import Affjax as AX
import Effect.Aff (Aff, runAff_)
import Affjax.ResponseFormat as ResponseFormat
import Data.Either (Either(..), hush)
import Data.Maybe (Maybe(..))
import Data.HTTP.Method (Method(..))

import Effect.Class.Console (log)

import Simple.JSON (readJSON)

import Egg.Types.Level (JSONLevel)

import Egg.Types.ResourceUrl (ResourceUrl(..))

readLevel :: String -> Maybe JSONLevel
readLevel = hush <<< readJSON

levelLoader :: ResourceUrl -> Aff String
levelLoader resource = do
  AX.request (AX.defaultRequest { url = (show resource), method = Left GET, responseFormat = ResponseFormat.string })

getFirstLevel :: Effect Unit
getFirstLevel = do
  runAff_ callback (levelLoader (LevelResource 1))
  pure unit
    where
      callback a = case join (hush a) of
        Nothing -> log "Failed!"
        Just s  -> log (show s)

module Egg.Dom.Loader where

import Prelude

import Affjax as AX
import Effect.Aff (Aff)
import Affjax.ResponseFormat as ResponseFormat
import Data.Either (Either(..), hush)
import Data.Maybe (Maybe)
import Data.HTTP.Method (Method(..))
import Effect.Class (liftEffect)
import Effect.Console (log)


import Egg.Types.Level (Level)

import Egg.Types.ResourceUrl (ResourceUrl(..))
import Egg.Logic.LoadLevel (readLevel)

levelLoader :: ResourceUrl -> Aff (Maybe String)
levelLoader resource = do
  res <- AX.request settings
  pure (hush res.body)
    where
      settings = 
        (AX.defaultRequest 
          { url = (show resource)
          , method = Left GET
          , responseFormat = ResponseFormat.string 
          }
        )

getFirstLevel :: Aff (Maybe Level)
getFirstLevel = do
  maybeStr <- levelLoader (LevelResource 1)
  let level = maybeStr >>= readLevel
  liftEffect $ log (show level)
  pure level

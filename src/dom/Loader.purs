module Egg.Dom.Loader where

import Prelude
import Affjax as AX
import Effect.Aff (Aff)
import Affjax.ResponseFormat as ResponseFormat
import Data.Either (Either(..), hush)
import Data.Maybe (Maybe)
import Data.HTTP.Method (Method(..))
import Egg.Types.Level (Level)
import Egg.Types.ResourceUrl (ResourceUrl(..))
import Egg.Logic.LoadLevel (readLevel)
import Egg.Types.GamePlayType (LevelUrl)

levelLoader :: ResourceUrl -> Aff (Maybe String)
levelLoader resource = do
  res <- AX.request settings
  pure (hush res.body)
  where
  settings =
    ( AX.defaultRequest
        { url = (show resource)
        , method = Left GET
        , responseFormat = ResponseFormat.string
        }
    )

loadLevelFromUrl :: LevelUrl -> Aff (Maybe Level)
loadLevelFromUrl url = do
  maybeStr <- levelLoader (RemoteLevelResource url)
  pure $ maybeStr >>= readLevel

loadLevel :: Int -> Aff (Maybe Level)
loadLevel i = do
  maybeStr <- levelLoader (LevelResource i)
  let
    level = maybeStr >>= readLevel
  pure level

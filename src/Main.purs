module Main where

import Data.List
import Data.Either
import Effect (Effect)
import Effect.Console as Console
import Prelude (Unit, discard, pure, show, unit)
import Effect.Aff (runAff_)
import Egg.Canvas (setupGame)

import Egg.Types.ResourceUrl (ResourceUrl)
import Egg.Data.TileSet (tileResources)
import Egg.Dom.Loader (getFirstLevel)

import Egg.Logic.LoadLevel

main :: Effect Unit
main = do
  runAff_ (\a -> case a of
    Right _ -> Console.log "Everything went great"
    Left e  -> Console.error (show e)
  ) (setupGame imageResources)
  runAff_ (\a -> pure unit) getFirstLevel
  pure unit

imageResources :: List ResourceUrl
imageResources = tileResources

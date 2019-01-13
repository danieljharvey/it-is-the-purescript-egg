module Main where

import Data.Either
import Effect (Effect)
import Effect.Console as Console
import Prelude (Unit, discard, pure, show, unit)
import Effect.Aff (runAff_)
import Egg.Canvas (setupGame)

import Egg.Types.ResourceUrl (ResourceUrl)
import Egg.Data.TileSet (tileResources)

main :: Effect Unit
main = do
  runAff_ (\a -> case a of
    Right _ -> Console.log "Everything went great"
    Left e  -> Console.error (show e)
  ) (setupGame imageResources)
  pure unit

imageResources :: Array ResourceUrl
imageResources = tileResources

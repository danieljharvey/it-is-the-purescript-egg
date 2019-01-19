module Main where

import Data.List (List)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Console as Console
import Prelude (Unit, discard, pure, show, unit)
import Effect.Aff (runAff_)
import Egg.Canvas (setupCanvas)

import Egg.Types.ResourceUrl (ResourceUrl)
import Egg.Data.TileSet (tileResources)
import Egg.Dom.Loader (loadLevel)


main :: Effect Unit
main = do
  runAff_ (\a -> case a of
    Right _ -> Console.log "Everything went great"
    Left e  -> Console.error (show e)
  ) (setupCanvas imageResources)
  runAff_ (\a -> pure unit) (loadLevel 1)
  pure unit

imageResources :: List ResourceUrl
imageResources = tileResources

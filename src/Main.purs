module Main where

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (log)
import Prelude (Unit, bind, discard, pure, unit)

import Egg.Canvas (getCanvas, setupGame)

main :: Effect Unit
main = do
  maybeElement <- getCanvas
  case maybeElement of
    Just element -> do
                    _ <- setupGame element
                    log "Ready!"
    _            -> log "Oh no!"
  pure unit

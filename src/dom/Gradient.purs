module Egg.Dom.Gradient where

import Effect
import Data.Int (toNumber)
import Graphics.Canvas

background :: Int -> LinearGradient
background size 
  = { x0: 0.0
    , y0: 0.0
    , x1: toNumber (size)
    , y1: toNumber (size)
    }

drawBackground :: Int -> Context2D -> Effect Unit
drawBackground size context = do
  canvasGradient <- createLinearGradient context (background size)
  pure unit
module Egg.Dom.Gradient where

import Prelude
import Effect (Effect)
import Data.Int (toNumber)
import Graphics.Canvas

background :: Int -> LinearGradient
background size 
  = { x0: toNumber (size / 2)
    , y0: 0.0
    , x1: toNumber (size / 2)
    , y1: toNumber (size)
    }

getGradient:: Int -> Context2D -> Effect CanvasGradient
getGradient size context = do
  canvasGradient <- createLinearGradient context (background size)
  addColorStop canvasGradient 1.0 "#152b26"
  addColorStop canvasGradient 0.8 "#102029"
  addColorStop canvasGradient 0.6 "#192b34"
  addColorStop canvasGradient 0.0 "#dd8888"
  pure canvasGradient
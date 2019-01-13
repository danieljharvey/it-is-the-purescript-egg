module Egg.Data.CanvasData (CanvasData, ImageSourceMap) where

import Data.Map as Map
import Egg.Types.ResourceUrl (ResourceUrl)
import Graphics.Canvas (CanvasImageSource, CanvasElement, Context2D)

type ImageSourceMap = (Map.Map ResourceUrl CanvasImageSource)

type CanvasData
  = { element    :: CanvasElement
    , context    :: Context2D
    , imageMap   :: ImageSourceMap
    , canvasSize :: Int
    }

module Egg.Types.Canvas (CanvasData, CanvasInfo, ImageSourceMap) where

import Data.Map as Map
import Egg.Types.ResourceUrl (ResourceUrl)
import Graphics.Canvas (CanvasImageSource, CanvasElement, Context2D)

type ImageSourceMap = (Map.Map ResourceUrl CanvasImageSource)

type CanvasInfo 
  = { element :: CanvasElement
    , context :: Context2D
    , size    :: Int
    }

type CanvasData
  = { buffer   :: CanvasInfo
    , screen   :: CanvasInfo
    , imageMap :: ImageSourceMap
    }

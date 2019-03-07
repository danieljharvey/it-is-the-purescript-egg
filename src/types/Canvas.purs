module Egg.Types.Canvas (CanvasData, ImageSourceMap) where

import Data.Map as Map
import Egg.Types.ResourceUrl (ResourceUrl)
import Graphics.Canvas (CanvasImageSource, CanvasElement, Context2D)

type ImageSourceMap = (Map.Map ResourceUrl CanvasImageSource)

type CanvasData
  = { buffer :: { element         :: CanvasElement
                , context         :: Context2D
                }
    , screen :: { element         :: CanvasElement
                , context         :: Context2D
                }
    , imageMap                    :: ImageSourceMap
    , canvasSize                  :: Int
    }

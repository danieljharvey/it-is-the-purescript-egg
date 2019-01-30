module Egg.Dom.Renderer where

import Prelude
import Effect (Effect)
import Data.Array (filter)
import Data.Traversable (traverse)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Map as M

import Egg.Types.Level (Level)
import Egg.Types.Canvas (CanvasData, ImageSourceMap)
import Egg.Types.Board (Board, RenderItem, RenderMap)
import Egg.Types.Coord (Coord, createCoord)
import Egg.Logic.RenderMap (blankRenderMap, shouldDrawItem)
import Egg.Types.ResourceUrl (ResourceUrl(..))
import Egg.Dom.Canvas as Canvas

import Graphics.Canvas (CanvasImageSource)
import Matrix as Mat

renderLevel :: CanvasData -> Level -> Maybe RenderMap -> Effect Unit
renderLevel canvasData level mRenderMap
  = do
    let renderMap = fromMaybe (blankRenderMap level.boardSize) mRenderMap
    render canvasData renderMap level.board

toCoord :: RenderItem -> Coord
toCoord item
 = createCoord item.x item.y

findImageSource :: ImageSourceMap -> String -> Maybe CanvasImageSource
findImageSource sourceMap src
  = M.lookup (TileResource src) sourceMap

render :: CanvasData -> RenderMap -> Board -> Effect Unit
render canvasData renderMap board
  = do
      let items = filter (shouldDrawItem renderMap) (Mat.toIndexedArray board)
      _ <- traverse (drawRenderItem canvasData) items
      pure unit

drawRenderItem :: CanvasData -> RenderItem -> Effect Unit
drawRenderItem canvasData item
  = do
      let imageSource = findImageSource (canvasData.imageMap) item.value.img
      case imageSource of
        Just img -> Canvas.drawTile (canvasData.context) img (toCoord item)
        Nothing -> pure unit

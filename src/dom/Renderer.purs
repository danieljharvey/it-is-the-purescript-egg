module Egg.Dom.Renderer where

import Prelude
import Effect (Effect)
import Data.Array (filter)
import Data.Traversable (traverse)
import Data.Maybe (Maybe(..))
import Data.Map as M

import Egg.Types.CurrentFrame (getCurrentFrame)
import Egg.Types.Player (Player)
import Egg.Types.ResourceUrl (ResourceUrl)
import Egg.Types.GameState (GameState)
import Egg.Types.Canvas (CanvasData, ImageSourceMap)
import Egg.Types.Board (Board, RenderItem, RenderMap)
import Egg.Types.Coord (Coord, createCoord)

import Egg.Logic.RenderMap (boardSizeFromBoard, gameStatesToRenderMap, getRenderList, shouldDrawItem)

import Egg.Dom.Canvas as Canvas

import Graphics.Canvas (CanvasImageSource)
import Matrix as Mat

renderGameState :: CanvasData -> GameState -> GameState -> Effect Unit
renderGameState canvasData old new = do
  let renderMap = gameStatesToRenderMap old new
  Canvas.clearScreen canvasData.context (boardSizeFromBoard new.board)
  clearTiles canvasData renderMap
  renderBoard canvasData renderMap new.board
  renderPlayers canvasData new.players
  showRenderingTiles canvasData renderMap

showRenderingTiles :: CanvasData -> RenderMap -> Effect Unit
showRenderingTiles canvasData renderMap = do
  let clearList = getRenderList renderMap
  _ <- traverse (\coord -> Canvas.fillTile canvasData.context coord) clearList
  pure unit

clearTiles :: CanvasData -> RenderMap -> Effect Unit
clearTiles canvasData renderMap = do
  let clearList = getRenderList renderMap
  _ <- traverse (\coord -> Canvas.clearTile canvasData.context coord) clearList
  pure unit

toCoord :: RenderItem -> Coord
toCoord item
 = createCoord item.x item.y

findImageSource :: ImageSourceMap -> ResourceUrl -> Maybe CanvasImageSource
findImageSource sourceMap src
  = M.lookup src sourceMap

renderPlayers :: CanvasData -> Array Player -> Effect Unit
renderPlayers canvasData players
  = const unit <$> traverse (renderPlayer canvasData) players

renderPlayer :: CanvasData -> Player -> Effect Unit
renderPlayer canvasData player = do
  let imageSource = findImageSource canvasData.imageMap player.playerType.img
  case imageSource of
    Just img -> Canvas.drawPlayer (canvasData.context) img player.coords (getCurrentFrame player.currentFrame)
    Nothing  -> pure unit

renderBoard :: CanvasData -> RenderMap -> Board -> Effect Unit
renderBoard canvasData renderMap board
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
        Nothing  -> pure unit

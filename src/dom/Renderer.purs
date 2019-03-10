module Egg.Dom.Renderer where

import Prelude

import Data.Array (filter)
import Data.Map as M
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Egg.Dom.Canvas as Canvas
import Egg.Types.Board (Board, RenderItem, RenderMap)
import Egg.Types.Canvas (CanvasData, ImageSourceMap)
import Egg.Types.Coord (Coord, createCoord)
import Egg.Types.CurrentFrame (getCurrentFrame)
import Egg.Types.GameState (GameState)
import Egg.Types.Player (Player)
import Egg.Logic.RenderMap (addEdgePlayers, gameStatesToRenderMap, getRenderList, shouldDrawItem)
import Egg.Types.ResourceUrl (ResourceUrl)
import Graphics.Canvas (CanvasImageSource)
import Matrix as Mat

renderGameState :: CanvasData -> GameState -> GameState -> Effect Unit
renderGameState canvasData old new = do
  let renderMap = gameStatesToRenderMap old new
  clearTiles canvasData renderMap
  renderBoard canvasData renderMap new.board
  renderPlayers canvasData new.board new.players
  -- showRenderingTiles canvasData renderMap
  Canvas.copyBufferToCanvas canvasData.buffer canvasData.screen

showRenderingTiles :: CanvasData -> RenderMap -> Effect Unit
showRenderingTiles canvasData renderMap = do
  let clearList = getRenderList renderMap
  _ <- traverse (\coord -> Canvas.fillTile canvasData.buffer.context coord) clearList
  pure unit

clearTiles :: CanvasData -> RenderMap -> Effect Unit
clearTiles canvasData renderMap = do
  let clearList = getRenderList renderMap
  _ <- traverse (\coord -> Canvas.clearTile canvasData.buffer.context coord) clearList
  pure unit

toCoord :: RenderItem -> Coord
toCoord item
 = createCoord item.x item.y

findImageSource :: ImageSourceMap -> ResourceUrl -> Maybe CanvasImageSource
findImageSource sourceMap src
  = M.lookup src sourceMap

renderPlayers :: CanvasData -> Board -> Array Player -> Effect Unit
renderPlayers canvasData board players
  = const unit <$> traverse (renderPlayer canvasData) allPlayers
  where
    allPlayers
      = addEdgePlayers board players

renderPlayer :: CanvasData -> Player -> Effect Unit
renderPlayer canvasData player = do
  let imageSource = findImageSource canvasData.imageMap player.playerType.img
  case imageSource of
    Just img -> Canvas.drawPlayer (canvasData.buffer.context) img player.coords (getCurrentFrame player.currentFrame)
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
        Just img -> Canvas.drawTile (canvasData.buffer.context) img (toCoord item)
        Nothing  -> pure unit

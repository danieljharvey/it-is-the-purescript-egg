module Egg.Dom.Renderer where

import Prelude

import Data.Array (filter)
import Data.Function (applyN)
import Data.Map as M
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Egg.Dom.Canvas as Canvas
import Egg.Types.Board (Board, BoardSize, RenderItem, RenderMap)
import Egg.Types.Canvas (CanvasData, ImageSourceMap)
import Egg.Types.Coord (Coord, createCoord)
import Egg.Types.Clockwise (Clockwise(..))
import Egg.Types.CurrentFrame (getCurrentFrame)
import Egg.Types.GameState (GameState)
import Egg.Types.Player (Player)
import Egg.Types.RenderAngle (RenderAngle(..))
import Egg.Types.ResourceUrl (ResourceUrl)
import Egg.Logic.Board (boardSizeFromBoard)
import Egg.Logic.Map as Map
import Egg.Logic.RenderMap (addEdgePlayers, gameStatesToRenderMap, getRenderList, shouldDrawItem)


import Graphics.Canvas (CanvasImageSource)
import Matrix as Mat

renderGameState :: CanvasData -> GameState -> GameState -> Effect Unit
renderGameState canvasData old new = do
  let renderMap = getBoardForRender new.rotateAngle (gameStatesToRenderMap old new)
  clearTiles canvasData renderMap
  renderBoard canvasData renderMap (getBoardForRender new.rotateAngle new.board)
  renderPlayers canvasData new.board (getPlayersForRender new.rotateAngle new.board new.players)
  --showRenderingTiles canvasData renderMap
  Canvas.copyBufferToCanvas canvasData.buffer canvasData.screen (calcRenderAngle new)

getPlayersForRender :: RenderAngle -> Board -> Array Player -> Array Player
getPlayersForRender (RenderAngle 90) board players 
  = rotatePlayer (boardSizeFromBoard board) AntiClockwise <$> players
getPlayersForRender (RenderAngle 180) board players 
  = applyN (rotatePlayer (boardSizeFromBoard board) AntiClockwise <$> _) 2 players
getPlayersForRender (RenderAngle 270) board players 
  = rotatePlayer (boardSizeFromBoard board) Clockwise <$> players
getPlayersForRender _ _ players
  = players

rotatePlayer :: BoardSize -> Clockwise -> Player -> Player
rotatePlayer size clockwise player
  = rotated { coords = newCoords }
  where
    newCoords
      = rotated.coords <> rotatedCoords
    rotated
      = Map.rotatePlayer size clockwise player
    rotatedCoords
      = Map.rotateOffset clockwise player.coords


-- we want stuff the right way up so we turn board the wrong way and then render it rotated
getBoardForRender :: forall a. RenderAngle -> Mat.Matrix a -> Mat.Matrix a 
getBoardForRender (RenderAngle 90) board 
  = Map.rotateBoard AntiClockwise board
getBoardForRender (RenderAngle 180) board 
  = applyN (Map.rotateBoard AntiClockwise) 2 $ board
getBoardForRender (RenderAngle 270) board 
  = Map.rotateBoard Clockwise board
getBoardForRender _ board 
  = board

calcRenderAngle :: GameState -> RenderAngle
calcRenderAngle gs
  = gs.renderAngle <> gs.rotateAngle

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

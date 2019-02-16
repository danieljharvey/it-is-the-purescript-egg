module Egg.Logic.RenderMap where

import Prelude
import Data.Maybe (fromMaybe)
import Matrix as Mat
import Egg.Types.Player (Player)
import Egg.Types.Board (Board, BoardSize, RenderArray, RenderItem, RenderMap)
import Egg.Types.Coord
import Egg.Types.GameState (GameState)
import Data.Array (filter, range)
import Data.Traversable (foldr)

gameStatesToRenderMap :: GameState -> GameState -> RenderMap
gameStatesToRenderMap old new
  = addPlayersToRenderMap new.players boardMap
  where
    boardMap
      = createRenderMap old.board new.board

createRenderMap :: Board -> Board -> RenderMap
createRenderMap before after
  = fromMaybe blankMap renderMap
  where
    blankMap
      = blankRenderMap before

    renderMap
      = Mat.zipWith compare before after

    compare a b
      = a /= b

addPlayersToRenderMap :: Array Player -> RenderMap -> RenderMap
addPlayersToRenderMap players rMap
  = foldr addPlayerToRenderMap rMap players

addPlayerToRenderMap :: Player -> RenderMap -> RenderMap
addPlayerToRenderMap player map
  = foldr markCoord map coordList
  where
    coordList
      = getPlayerCoordList map player

    markCoord (Coord coord) rMap
      = fromMaybe rMap (Mat.set coord.x coord.y true rMap)

getPlayerCoordList :: RenderMap -> Player -> Array Coord
getPlayerCoordList map player = do
  let (Coord coords) = player.coords
  xs <- range (coords.x - 1) (coords.x + 1)
  ys <- range (coords.y - 1) (coords.y + 1)
  pure (createCoord (xs `mod` maxX) (ys `mod` maxY))
    where
      maxX = Mat.width map
      maxY = Mat.height map

boardSizeFromBoard :: Board -> BoardSize
boardSizeFromBoard board =
  { width : Mat.width board
  , height: Mat.height board
  }

blankRenderMap :: Board -> RenderMap
blankRenderMap board = Mat.repeat (Mat.width board) (Mat.height board) true

getRenderList :: RenderMap -> Array Coord
getRenderList rMap
  = map (\item -> createCoord item.x item.y) filtered
  where
    filtered
      = filter (\item -> item.value == true) (Mat.toIndexedArray rMap)

shouldDrawItem :: RenderMap -> RenderItem -> Boolean
shouldDrawItem map item
  = shouldDraw map (createCoord item.x item.y)

shouldDraw :: RenderMap -> Coord -> Boolean
shouldDraw map (Coord coord) = fromMaybe false draw
  where
    draw = Mat.get coord.x coord.y map

buildRenderArray :: RenderMap -> Board -> RenderArray
buildRenderArray map board = filter filterFunc array
  where
    filterFunc item
      = shouldDraw map (createCoord item.x item.y)

    array = Mat.toIndexedArray board

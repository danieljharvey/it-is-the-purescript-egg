module Egg.Logic.RenderMap where

import Prelude
import Data.Maybe (fromMaybe)
import Matrix as Mat
import Egg.Types.Player (Player)
import Egg.Types.Board (Board, BoardSize, RenderArray, RenderItem, RenderMap)
import Egg.Logic.Board (boardSizeFromBoard)
import Egg.Types.Coord (Coord(..), createCoord, invert, totalX, totalY)
import Egg.Types.GameState (GameState)
import Egg.Types.Tile (tileSize)
import Data.Array (filter, range)
import Data.Traversable (foldr)

gameStatesToRenderMap :: GameState -> GameState -> RenderMap
gameStatesToRenderMap old new
  = if needsFullRefresh old new 
      then fillWholeBoard true new.board
      else addPlayersToRenderMap new.players boardMap
  where
    boardMap
      = createRenderMap old.board new.board

needsFullRefresh :: GameState -> GameState -> Boolean
needsFullRefresh old new
  = old.rotateAngle /= new.rotateAngle

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

fillWholeBoard :: Boolean -> Board -> RenderMap
fillWholeBoard value board
  = Mat.repeat (Mat.width board) (Mat.height board) value

blankRenderMap :: Board -> RenderMap
blankRenderMap = fillWholeBoard false

getRenderList :: RenderMap -> Array Coord
getRenderList rMap
  = map (\item -> createCoord item.x item.y) filtered
  where
    filtered
      = filter (\item -> item.value == true) (Mat.toIndexedArray rMap)

shouldDrawItem :: RenderMap -> RenderItem -> Boolean
shouldDrawItem map item
  = shouldDraw map (createCoord item.x item.y) 
  && item.value.drawMe

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

-- when a player is on the edge of the map, add a duplicate on other side for rendering
addEdgePlayers :: Board -> Array Player -> Array Player
addEdgePlayers board players
  = join $ addPlayers (boardSizeFromBoard board) <$> players

addPlayers :: BoardSize -> Player -> Array Player
addPlayers size player
  = [player] <> left <> right <> top <> bottom
  where
    height
      = size.height - 1
    width 
      = size.width - 1
    left
      = if totalX player.coords < 0 
        then [ player { coords = player.coords <> (createCoord (width + 1) 0) } ]
        else mempty
    right
      = if totalX player.coords > width * tileSize
        then [ player { coords = player.coords <> invert (createCoord (width + 1) 0) } ]
        else mempty
    top
      = if totalY player.coords < 0 
        then [ player { coords = player.coords <> (createCoord 0 (height + 1)) } ]
        else mempty
    bottom
      = if totalY player.coords > height * tileSize
        then [ player { coords = player.coords <> invert (createCoord 0 (height + 1)) } ]
        else mempty
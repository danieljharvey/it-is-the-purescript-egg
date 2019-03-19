module Egg.Logic.Map where

import Prelude
import Egg.Logic.Board (boardSizeFromBoard)
import Egg.Types.Board (Board, BoardSize, GenericRenderItem)
import Egg.Types.Coord (Coord(..), center, createCoord, createFullCoord)
import Egg.Types.Player (Player)
import Egg.Logic.Movement (isStationary)
import Egg.Types.Clockwise (Clockwise(..))
import Egg.Types.RenderAngle (RenderAngle(..), decrease, increase)
import Egg.Types.Tile (Tile)
import Egg.Data.TileSet (tiles)
import Data.Map as M
import Data.Maybe (Maybe, fromMaybe)
import Data.Array (filter, head)
import Matrix as Mat

translateRotation
  :: BoardSize
  -> Coord
  -> Clockwise
  -> Coord
translateRotation size (Coord coord) clockwise
  = case clockwise of
      Clockwise     -> right
      AntiClockwise -> left
  where
    width 
      = size.width - 1
    height 
      = size.height - 1
    right
      = Coord 
          $ coord { x = width - coord.y
                  , y = coord.x
                  }
    left 
      = Coord 
          $ coord { x = coord.y
                  , y = height - coord.x
                  }

getNewPlayerDirection :: Coord -> Clockwise -> Coord
getNewPlayerDirection coord clockwise
  = if isStationary coord 
    then newCoord
    else coord
  where
    newCoord
      = case clockwise of
          Clockwise     -> createCoord 1 0 
          AntiClockwise -> createCoord (-1) 0

rotateBoard 
  :: forall a
   . Clockwise 
  -> Mat.Matrix a 
  -> Mat.Matrix a
rotateBoard clockwise board
  = Mat.indexedMap mapItem board
  where
    items
      = updateRenderItem size clockwise <$> Mat.toIndexedArray board
    size
      = boardSizeFromBoard board
    mapItem x y a
      = fromMaybe a (findArrayItem (createCoord x y) items)

findArrayItem 
  :: forall a
   . Coord 
  -> Array (GenericRenderItem a) 
  -> Maybe a
findArrayItem (Coord coord) items
  = _.value <$> foundItem
  where
    foundItem
      = head $ filter (\item -> item.x == coord.x && item.y == coord.y) items 

updateRenderItem :: forall a. BoardSize -> Clockwise -> GenericRenderItem a -> GenericRenderItem a
updateRenderItem size clockwise { x, y, value: tile }
  = { x: newCoord.x, y: newCoord.y, value: tile }
  where
    (Coord newCoord)
      = translateRotation size (createCoord x y) clockwise

changeRenderAngle :: RenderAngle -> Clockwise -> RenderAngle
changeRenderAngle angle clockwise
  = case clockwise of
      Clockwise     -> increase angle (RenderAngle 90)
      AntiClockwise -> decrease angle (RenderAngle 90)

rotatePlayer :: BoardSize -> Clockwise -> Player -> Player
rotatePlayer size clockwise player
  = player { coords = newCoords, direction = direction }
  where
    newCoords
      = center (translateRotation size player.coords clockwise)
    direction
      = getNewPlayerDirection player.direction clockwise

rotateOffset :: Clockwise -> Coord -> Coord
rotateOffset Clockwise (Coord c)
  = createFullCoord 0 0 (-1 * c.offsetY) c.offsetX
rotateOffset AntiClockwise (Coord c)
  = createFullCoord 0 0 c.offsetY (-1 * c.offsetX)

switchTiles :: Int -> Int -> Board -> Board
switchTiles oldId newId board = 
  map (switchTile oldId newId) board

switchTile :: Int -> Int -> Tile -> Tile
switchTile oldId newId tile
  = change oldId newId (change newId oldId tile)
  where
    change from to tile'
      = if tile.id == from
        then fromMaybe tile' (M.lookup to tiles)
        else tile'

{-

export const correctForOverflow = (board: Board, coords: Coords): Coords => {
  const boardSize = calcBoardSize(board);
  return Utils.correctForOverflow(coords, new BoardSize(boardSize));
};

// is intended next tile empty / a wall?
// need to make this wrap around the board
export const checkTileIsEmpty = (board: Board, x, y): boolean => {
  const tile = getTile(board, x, y);
  return tile.background;
};

// find random tile of type that is NOT at currentCoords
export const findTile = (board: Board, currentCoords: Coords, id): Tile => {
  const tiles = board.getAllTiles();
  const teleporters = tiles.filter(tile => {
    if (tile.x === currentCoords.x && tile.y === currentCoords.y) {
      return false;
    }
    return tile.id === id;
  });
  if (teleporters.size === 0) {
    return null;
  }
  const chosenID = Math.floor(Math.random() * teleporters.size);

  const newTile = teleporters.get(chosenID); // this is an Immutable list so needs to use their functions
  return newTile;
};

export const getRandomTile = (tiles): Tile => {
  const randomProperty = obj => {
    const randomKey = Utils.getRandomObjectKey(obj);
    return cloneTile(randomKey);
  };

  (Object as any).entries(tiles).filter(([key, tile]) => {
    if (tile.dontAdd) {
      delete tiles[key];
    }
    return true;
  });
  return randomProperty(tiles);
};



export const generateRandomBoard = (boardSize: BoardSize): Board => {
  const boardArray = [];

  for (let x = 0; x < boardSize.width; x++) {
    boardArray[x] = [];
    for (let y = 0; y < boardSize.height; y++) {
      const blankTile = getRandomTile(allTiles);
      const positionedTile = blankTile.modify({
        x,
        y
      });
      boardArray[x][y] = blankTile;
    }
  }
  return new Board(boardArray);
};

-}
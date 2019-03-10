module Egg.Logic.Map where

import Prelude
import Egg.Logic.Board (boardSizeFromBoard)
import Egg.Types.Board (Board, BoardSize, RenderItem)
import Egg.Types.Coord (Coord(..), center, createCoord)
import Egg.Types.Player (Player)
import Egg.Logic.Movement (isStationary)
import Egg.Types.Clockwise (Clockwise(..))
import Egg.Types.Tile (Tile)
import Egg.Types.RenderAngle (RenderAngle(..), decrease, increase)
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

rotateBoard :: Board -> Clockwise -> Board
rotateBoard board clockwise
  = Mat.indexedMap mapItem board
  where
    items
      = updateRenderItem size clockwise <$> Mat.toIndexedArray board
    size
      = boardSizeFromBoard board
    mapItem x y a
      = fromMaybe a (findArrayItem (createCoord x y) items)

findArrayItem :: Coord -> Array RenderItem -> Maybe Tile
findArrayItem (Coord coord) items
  = _.value <$> foundItem
  where
    foundItem
      = head $ filter (\item -> item.x == coord.x && item.y == coord.y) items 

updateRenderItem :: BoardSize -> Clockwise -> RenderItem -> RenderItem
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

export const getTileWithCoords = (board: Board, coords: Coords): Tile => {
  const fixedCoords = correctForOverflow(board, coords);
  const { x, y } = fixedCoords;
  return board.getTile(x, y);
};

export const changeTile = (board: Board, coords: Coords, tile: Tile): Board => {
  return board.modify(coords.x, coords.y, tile);
};

export const getNewPlayerDirection = (direction, clockwise) => {
  if (direction.x !== 0 || direction.y !== 0) {
    return direction;
  }
  return clockwise ? new Coords({ x: 1 }) : new Coords({ x: -1 });
};

export const rotatePlayer = (
  boardSize: BoardSize,
  player: Player,
  clockwise
): Player => {
  const newCoords = translateRotation(boardSize, player.coords, clockwise);

  return player.modify({
    coords: newCoords.modify({
      offsetX: 0,
      offsetY: 0
    }),
    direction: getNewPlayerDirection(player.direction, clockwise)
  });
};

export const cloneTile = (id): Tile => {
  const prototypeTile = getPrototypeTile(id);
  return new Tile(prototypeTile); // create new Tile object with these
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

// swap two types of tiles on map (used by pink/green switching door things)
export const switchTiles = (board: Board, id1, id2): Board => {
  const tiles = board.getAllTiles();
  return tiles.reduce((currentBoard, tile) => {
    if (tile.id === id1) {
      const newTile = cloneTile(id2);
      const positionTile = newTile.modify({
        x: tile.x,
        y: tile.y
      });
      return currentBoard.modify(tile.x, tile.y, positionTile);
    } else if (tile.id === id2) {
      const newTile = cloneTile(id1);
      const positionTile = newTile.modify({
        x: tile.x,
        y: tile.y
      });
      return currentBoard.modify(tile.x, tile.y, positionTile);
    }
    return currentBoard;
  }, board);
};

export const changeRenderAngle = (renderAngle: number, clockwise: boolean) => {
  let newRenderAngle;
  if (clockwise) {
    newRenderAngle = renderAngle + 90;
    if (newRenderAngle > 360) {
      newRenderAngle = newRenderAngle - 360;
    }
    return newRenderAngle;
  }

  newRenderAngle = renderAngle - 90;
  if (newRenderAngle < 0) {
    newRenderAngle = 360 + newRenderAngle;
  }
  return newRenderAngle;
};

export const makeBoardFromArray = (boardArray: Tile[][] = []): Board => {
  const newBoard = boardArray.map((column, mapX) => {
    return column.map((item, mapY) => {
      const newTile = cloneTile(item.id);
      return newTile.modify({
        x: mapX,
        y: mapY
      });
    });
  });
  return new Board(newBoard);
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
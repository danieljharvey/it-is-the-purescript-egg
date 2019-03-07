module Test.Logic.Action where

import Prelude (Unit, discard, negate, ($), (*))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions
import Data.Maybe (fromMaybe)

import Egg.Types.Board (Board)
import Egg.Types.Tile (Tile, defaultTile)
import Egg.Types.Coord (Coord(..), createCoord)
import Egg.Types.Player (Player, defaultPlayer)
import Egg.Logic.Movement (calcMoveAmount, checkFloorBelowPlayer, checkPlayerDirection, correctTileOverflow, incrementPlayerDirection, incrementPlayerFrame, markPlayerIfMoved, playerHasMoved)
import Egg.Types.CurrentFrame (createCurrentFrame, dec, getCurrentFrame)

import Matrix as Mat

bgTile :: Tile
bgTile = defaultTile { background = true, breakable = false }
    
breakable :: Tile
breakable = defaultTile { background = false, breakable = true }

empty :: Tile
empty = defaultTile { background = false, breakable = false }

boardFromArray :: Array (Array Tile) -> Board
boardFromArray tiles
  = fromMaybe Mat.empty $ Mat.fromArray tiles 

flyingPlayer :: Player
flyingPlayer = defaultPlayer { playerType = defaultPlayer.playerType { flying = true } }

tests :: Spec Unit
tests =
  describe "Action" do
    describe "empty tests" do
      it "Blah" do
        1 `shouldEqual` 1


{-


// create board with one Tile which is collectable
const makeSimpleBoard = () => {
  const tile = new Tile({
    x: 0,
    y: 0,
    collectable: 100
  });

  const boardArray = [[tile]];

  return new Board(boardArray);
};

test("Do nothing if player not centered on board in X axis", () => {
  const board = makeSimpleBoard();

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0,
      offsetX: 1
    })
  });

  const action = new Action();

  const output = action.checkPlayerTileAction(player, board, 0, "");

  expect(is(output.board, board)).toEqual(true);
});

test("Do nothing if player not centered on board in Y axis", () => {
  const board = makeSimpleBoard();

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0,
      offsetY: -10
    })
  });

  const action = new Action();

  const output = action.checkPlayerTileAction(player, board, 0, "");

  expect(is(output.board, board)).toEqual(true);
});

test("Do nothing if player has not moved", () => {
  const board = makeSimpleBoard();

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0
    }),
    moved: false
  });

  const action = new Action();

  const output = action.checkPlayerTileAction(player, board, 0, "");

  expect(is(output.board, board)).toEqual(true);
});

test("Change board if player has moved", () => {
  const board = makeSimpleBoard();

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0
    }),
    moved: true
  });

  const action = new Action();

  const output = action.checkPlayerTileAction(player, board, 0, "");

  expect(is(output.board, board)).toEqual(false);
  expect(output.score).toEqual(100); // tile was collected
});

-}
module Test.Logic.Action where

import Prelude (Unit, discard, ($))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions
import Data.Maybe (fromMaybe)

import Egg.Types.Player (defaultPlayer)
import Egg.Types.Coord (createFullCoord)
import Egg.Types.Board (Board)
import Egg.Types.Tile (Tile, defaultTile)
import Egg.Types.Score (Score(..))
import Egg.Types.Outcome (Outcome(..))

import Egg.Logic.Action (checkPlayerTileAction)

import Matrix as Mat

collectable :: Tile
collectable = defaultTile { background = true, breakable = false, collectable = 100 }
    
boardFromArray :: Array (Array Tile) -> Board
boardFromArray tiles
  = fromMaybe Mat.empty $ Mat.fromArray tiles 

collectableBoard :: Board
collectableBoard = boardFromArray [[collectable]]

tests :: Spec Unit
tests =
  describe "Action" do
    describe "checkPlayerTileAction" do
      it "Does nothing if player not centered on board in X axis" do
        let player = defaultPlayer { coords = createFullCoord 0 0 1 0
                                   }
        let after = checkPlayerTileAction player collectableBoard (Score 0) (Outcome "")
        after.board `shouldEqual` collectableBoard

      it "Does nothing if player not centered on board in Y axis" do
        let player = defaultPlayer { coords = createFullCoord 0 0 0 1
                                   }
        let after = checkPlayerTileAction player collectableBoard (Score 0) (Outcome "")
        after.board `shouldEqual` collectableBoard

      it "Does nothing if player has not moved" do
        let player = defaultPlayer { coords = createFullCoord 0 0 0 0
                                   , moved  = false
                                   }
        let after = checkPlayerTileAction player collectableBoard (Score 0) (Outcome "")
        after.board `shouldEqual` collectableBoard

{-

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
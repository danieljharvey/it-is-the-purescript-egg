module Test.Logic.Action where

import Test.Spec.Assertions

import Egg.Logic.Action (checkPlayerTileAction)
import Egg.Types.Board (Board)
import Egg.Logic.Board (boardFromArray)
import Egg.Types.Coord (createCoord, createFullCoord)
import Egg.Types.Outcome (Outcome(..))
import Egg.Types.Player (defaultPlayer)
import Egg.Types.Score (Score(..))
import Egg.Types.Tile (Tile, defaultTile)
import Egg.Types.TileAction (TileAction(..))
import Prelude (Unit, discard)
import Test.Spec (Spec, describe, it)

collectable :: Tile
collectable = defaultTile { action = Collectable 100 }

collectableBoard :: Board
collectableBoard = boardFromArray [[collectable]]

completeLevel :: Tile
completeLevel = defaultTile { action = CompleteLevel }

completeBoard :: Board
completeBoard = boardFromArray [[completeLevel]]

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
      
      it "Changes board and increments score if player has moved" do
        let player = defaultPlayer { coords = createFullCoord 0 0 0 0
                                   , moved  = true
                                   }
        let after = checkPlayerTileAction player collectableBoard (Score 0) (Outcome "")
        after.board `shouldNotEqual` collectableBoard
        after.score `shouldEqual` Score 100
      
      it "Returns 'completeLevel' outcome" do
        let player = defaultPlayer { coords = createCoord 0 0
                                   , moved  = true
                                   }
        let after = checkPlayerTileAction player completeBoard (Score 0) (Outcome "")
        after.board `shouldEqual` completeBoard
        after.outcome `shouldEqual` Outcome "completeLevel"

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
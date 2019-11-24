module Test.Logic.Action where

import Test.Spec.Assertions
import Egg.Logic.Action (checkPlayerTileAction, checkTileBelowPlayer)
import Egg.Types.Board (Board)
import Egg.Logic.Board (boardFromArray)
import Egg.Types.Coord (createCoord, createFullCoord)
import Egg.Types.Outcome (Outcome(..))
import Egg.Types.Player (defaultPlayer)
import Egg.Types.Score (Score(..))
import Egg.Types.Tile (Tile, defaultTile, emptyTile)
import Egg.Types.TileAction (SwitchColour(..), TileAction(..))
import Egg.Data.TileSet (tiles)
import Prelude (Unit, discard, (==), (||))
import Test.Spec (Spec, describe, it)
import Data.Foldable (foldr)
import Data.Maybe (fromMaybe)
import Data.Map as M

collectable :: Tile
collectable = defaultTile { action = Collectable 100 }

collectableBoard :: Board
collectableBoard = boardFromArray [ [ collectable ] ]

completeLevel :: Tile
completeLevel = defaultTile { action = CompleteLevel }

completeBoard :: Board
completeBoard = boardFromArray [ [ completeLevel ] ]

pinkSwitchTile :: Tile
pinkSwitchTile = defaultTile { action = Switch Pink }

pinkBlockTile :: Tile
pinkBlockTile = fromMaybe emptyTile (M.lookup 15 tiles)

pinkSwitchBoard :: Board
pinkSwitchBoard = boardFromArray [ [ pinkSwitchTile, pinkBlockTile ] ]

boardContainsId :: Int -> Board -> Boolean
boardContainsId i board = foldr (\tile total -> total || tile.id == i) false board

crateTile :: Tile
crateTile = defaultTile { breakable = true }

emptyBoard :: Board
emptyBoard = boardFromArray [ [ emptyTile ], [ emptyTile ] ]

smashableBoard :: Board
smashableBoard = boardFromArray [ [ emptyTile ], [ crateTile ] ]

tests :: Spec Unit
tests =
  describe "Action" do
    describe "checkPlayerTileAction" do
      it "Does nothing if player not centered on board in X axis" do
        let
          player =
            defaultPlayer
              { coords = createFullCoord 0 0 1 0
              }
        let
          after = checkPlayerTileAction player collectableBoard (Score 0) KeepPlaying
        after.board `shouldEqual` collectableBoard
      it "Does nothing if player not centered on board in Y axis" do
        let
          player =
            defaultPlayer
              { coords = createFullCoord 0 0 0 1
              }
        let
          after = checkPlayerTileAction player collectableBoard (Score 0) KeepPlaying
        after.board `shouldEqual` collectableBoard
      it "Does nothing if player has not moved" do
        let
          player =
            defaultPlayer
              { coords = createFullCoord 0 0 0 0
              , moved = false
              }
        let
          after = checkPlayerTileAction player collectableBoard (Score 0) KeepPlaying
        after.board `shouldEqual` collectableBoard
      it "Changes board and increments score if player has moved" do
        let
          player =
            defaultPlayer
              { coords = createFullCoord 0 0 0 0
              , moved = true
              }
        let
          after = checkPlayerTileAction player collectableBoard (Score 0) KeepPlaying
        after.board `shouldNotEqual` collectableBoard
        after.score `shouldEqual` Score 100
      it "Returns BackAtTheEggCup outcome" do
        let
          player =
            defaultPlayer
              { coords = createCoord 0 0
              , moved = true
              }
        let
          after = checkPlayerTileAction player completeBoard (Score 0) KeepPlaying
        after.board `shouldEqual` completeBoard
        after.outcome `shouldEqual` BackAtTheEggCup
      it "Triggers Pink switch" do
        let
          player =
            defaultPlayer
              { coords = createCoord 0 0
              , moved = true
              }
        let
          after = checkPlayerTileAction player pinkSwitchBoard (Score 0) KeepPlaying
        after.board `shouldNotEqual` pinkSwitchBoard
        boardContainsId 16 after.board `shouldEqual` true
      it "Does nothing when player is not falling" do
        let
          player =
            defaultPlayer
              { coords = createCoord 0 0
              }
        let
          after = checkTileBelowPlayer smashableBoard player
        after `shouldEqual` smashableBoard
      it "Does nothing when tile below is not smashable" do
        let
          player =
            defaultPlayer
              { coords = createCoord 0 0
              , falling = true
              }
        let
          after = checkTileBelowPlayer emptyBoard player
        after `shouldEqual` emptyBoard
      it "Smashes the crate below" do
        let
          player =
            defaultPlayer
              { coords = createCoord 0 0
              , falling = true
              }
        let
          after = checkTileBelowPlayer smashableBoard player
        after `shouldEqual` emptyBoard
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
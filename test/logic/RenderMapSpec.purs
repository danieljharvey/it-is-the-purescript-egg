module Test.Logic.RenderMap where

import Test.Spec.Assertions

import Egg.Types.GameState (createGameState)
import Egg.Logic.RenderMap (addEdgePlayers, fillWholeBoard, gameStatesToRenderMap)
import Egg.Types.Board (Board, emptyBoard)
import Egg.Types.Coord (createFullCoord)
import Egg.Types.Player (defaultPlayer)
import Egg.Types.RenderAngle (RenderAngle(..))
import Prelude (Unit, discard, negate)
import Test.Spec (Spec, describe, it)

testBoard :: Board
testBoard = emptyBoard 3

tests :: Spec Unit
tests =
  describe "RenderMap" do
    it "Render all after rotate" do
      let gameState = createGameState (testBoard)
          rotated = gameState { rotateAngle = RenderAngle 90 }
      gameStatesToRenderMap gameState rotated `shouldEqual` (fillWholeBoard true testBoard)

    describe "addEdgePlayers" do
      it "Duplicate on left" do
        let player = defaultPlayer { coords = createFullCoord 0 0 (-30) 0 }
        let second = defaultPlayer { coords = createFullCoord 3 0 (-30) 0 }
        addEdgePlayers testBoard [player] `shouldEqual` [player, second]
      it "Duplicate on right" do
        let player = defaultPlayer { coords = createFullCoord 3 0 30 0 }
        let second = defaultPlayer { coords = createFullCoord 0 0 30 0 }
        addEdgePlayers testBoard [player] `shouldEqual` [player, second]
      it "Duplicate on top" do
        let player = defaultPlayer { coords = createFullCoord 0 0 0 (-30) }
        let second = defaultPlayer { coords = createFullCoord 0 3 0 (-30) }
        addEdgePlayers testBoard [player] `shouldEqual` [player, second]
      it "Duplicate on bottom" do
        let player = defaultPlayer { coords = createFullCoord 0 3 0 30 }
        let second = defaultPlayer { coords = createFullCoord 0 0 0 30 }
        addEdgePlayers testBoard [player] `shouldEqual` [player, second]
module Test.Logic.RenderMap where

import Test.Spec.Assertions
import Egg.Types.Board (BoardSize)
import Egg.Types.Coord (Coord, createCoord)
import Egg.Types.Clockwise (Clockwise(..))
import Egg.Types.Tile (defaultTile, emptyTile)
import Egg.Logic.Board (boardFromArray)
import Egg.Logic.RenderMap
import Effect.Aff (Aff)
import Egg.Types.RenderAngle
import Prelude (Unit, discard, negate)
import Test.Spec (Spec, describe, it)
import Data.Traversable (traverse_)

tests :: Spec Unit
tests =
  describe "RenderMap" do
    describe "addEdgePlayers" do
      it "Test test" do
        1 `shouldEqual` 1
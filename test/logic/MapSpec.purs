module Test.Logic.Map where

import Test.Spec.Assertions
import Egg.Types.Board (BoardSize)
import Egg.Types.Coord (Coord, createCoord)
import Effect.Aff (Aff)
import Egg.Logic.Map (getNewPlayerDirection, translateRotation)

import Prelude (Unit, discard, negate)
import Test.Spec (Spec, describe, it)
import Data.Traversable (traverse_)

type RotateTest
  = { in        :: Coord
    , clockwise :: Boolean
    , out       :: Coord
    }

boardSize :: BoardSize
boardSize = { width: 10, height: 10 }

tryRotate :: RotateTest -> Aff Unit
tryRotate item = do
  translateRotation boardSize item.in item.clockwise `shouldEqual` item.out

tests :: Spec Unit
tests =
  describe "Map" do
    describe "translateRotation" do
      it "Does nothing if player not centered on board in X axis" do
        traverse_ tryRotate [ { in: createCoord 0 0, clockwise: true, out: createCoord 9 0 } 
                            , { in: createCoord 9 0, clockwise: true, out: createCoord 9 9 }
                            , { in: createCoord 9 9, clockwise: true, out: createCoord 0 9 }
                            , { in: createCoord 0 9, clockwise: true, out: createCoord 0 0 }
                            , { in: createCoord 0 0, clockwise: false, out: createCoord 0 9 }
                            , { in: createCoord 0 9, clockwise: false, out: createCoord 9 9 }
                            , { in: createCoord 9 9, clockwise: false, out: createCoord 9 0 }
                            , { in: createCoord 9 0, clockwise: false, out: createCoord 0 0 }
                            ]
                            
    describe "getNewPlayerDirection" do
      it "Doesn't get new player direction on rotate" do
        let direction = createCoord 1 0
        getNewPlayerDirection direction true `shouldEqual` direction
      
      it "Do get new player direction on clockwise rotate" do
        let direction = createCoord 0 0
        let expected  = createCoord 1 0
        getNewPlayerDirection direction true `shouldEqual` expected
      
      it "Do get new player direction on anti-clockwise rotate" do
        let direction = createCoord 0 0
        let expected  = createCoord (-1) 0
        getNewPlayerDirection direction false `shouldEqual` expected


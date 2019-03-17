module Test.Logic.Map where

import Test.Spec.Assertions
import Egg.Types.Board (BoardSize)
import Egg.Types.Coord (Coord, createCoord, createFullCoord)
import Egg.Types.Clockwise (Clockwise(..))
import Egg.Types.Tile (defaultTile, emptyTile)
import Egg.Logic.Board (boardFromArray)
import Egg.Logic.Map (changeRenderAngle, getNewPlayerDirection, rotateBoard, rotateOffset, translateRotation)
import Effect.Aff (Aff)
import Egg.Types.RenderAngle (RenderAngle(..))
import Prelude (Unit, discard, negate)
import Test.Spec (Spec, describe, it)
import Data.Traversable (traverse_)

type RotateTest
  = { in        :: Coord
    , clockwise :: Clockwise
    , out       :: Coord
    }

boardSize :: BoardSize
boardSize = { width: 10, height: 10 }

tryRotate :: RotateTest -> Aff Unit
tryRotate item
  = translateRotation boardSize item.in item.clockwise `shouldEqual` item.out

type ChangeAngleTest
  = { in        :: RenderAngle
    , clockwise :: Clockwise
    , out       :: RenderAngle
    }

tryChangeAngle :: ChangeAngleTest -> Aff Unit
tryChangeAngle item
  = changeRenderAngle item.in item.clockwise `shouldEqual` item.out

tests :: Spec Unit
tests =
  describe "Map" do
    describe "translateRotation" do
      it "Does nothing if player not centered on board in X axis" do
        traverse_ tryRotate [ { in: createCoord 0 0, clockwise: Clockwise, out: createCoord 9 0 } 
                            , { in: createCoord 9 0, clockwise: Clockwise, out: createCoord 9 9 }
                            , { in: createCoord 9 9, clockwise: Clockwise, out: createCoord 0 9 }
                            , { in: createCoord 0 9, clockwise: Clockwise, out: createCoord 0 0 }
                            , { in: createCoord 0 0, clockwise: AntiClockwise, out: createCoord 0 9 }
                            , { in: createCoord 0 9, clockwise: AntiClockwise, out: createCoord 9 9 }
                            , { in: createCoord 9 9, clockwise: AntiClockwise, out: createCoord 9 0 }
                            , { in: createCoord 9 0, clockwise: AntiClockwise, out: createCoord 0 0 }
                            ]
                            
    describe "getNewPlayerDirection" do
      it "Doesn't get new player direction on rotate" do
        let direction = createCoord 1 0
        getNewPlayerDirection direction Clockwise `shouldEqual` direction
      
      it "Do get new player direction on clockwise rotate" do
        let direction = createCoord 0 0
        let expected  = createCoord 1 0
        getNewPlayerDirection direction Clockwise `shouldEqual` expected
      
      it "Do get new player direction on anti-clockwise rotate" do
        let direction = createCoord 0 0
        let expected  = createCoord (-1) 0
        getNewPlayerDirection direction AntiClockwise `shouldEqual` expected
    
    describe "rotateBoard" do
      it "Rotates clockwise correctly" do
        let oldBoard = boardFromArray [ [ defaultTile, defaultTile, defaultTile]
                                      , [ defaultTile, emptyTile, emptyTile ]
                                      , [ defaultTile, emptyTile, emptyTile ] 
                                      ]
        let expected = boardFromArray [ [ defaultTile, defaultTile, defaultTile]
                                      , [ emptyTile, emptyTile, defaultTile ]
                                      , [ emptyTile, emptyTile, defaultTile ] 
                                      ]
        rotateBoard Clockwise oldBoard `shouldEqual` expected
      it "Rotates anticlockwise correctly" do
        let oldBoard = boardFromArray [ [ defaultTile, defaultTile, defaultTile]
                                      , [ emptyTile, emptyTile, defaultTile ]
                                      , [ emptyTile, emptyTile, defaultTile ] 
                                      ]
        let expected = boardFromArray [ [ defaultTile, defaultTile, defaultTile]
                                      , [ defaultTile, emptyTile, emptyTile ]
                                      , [ defaultTile, emptyTile, emptyTile ] 
                                      ]
        rotateBoard AntiClockwise oldBoard `shouldEqual` expected

    describe "changeRenderAngle" do
      it "Rotates correctly" do
        traverse_ tryChangeAngle [ { in: RenderAngle 0, clockwise: Clockwise, out: RenderAngle 90 }
                                 , { in: RenderAngle 90, clockwise: Clockwise, out: RenderAngle 180 } 
                                 , { in: RenderAngle 180, clockwise: Clockwise, out: RenderAngle 270 } 
                                 , { in: RenderAngle 270, clockwise: Clockwise, out: RenderAngle 0 } 
                                 , { in: RenderAngle 0, clockwise: AntiClockwise, out: RenderAngle 270 } 
                                 , { in: RenderAngle 90, clockwise: AntiClockwise, out: RenderAngle 0 } 
                                 , { in: RenderAngle 180, clockwise: AntiClockwise, out: RenderAngle 90 } 
                                 , { in: RenderAngle 270, clockwise: AntiClockwise, out: RenderAngle 180 } 
                                ]
    describe "rotateOffset" do
      it "Rotates anticlockwise" do
        rotateOffset AntiClockwise (createFullCoord 0 0 (-10) (-5)) `shouldEqual` createFullCoord 0 0 (-5) 10
      it "Rotates clockwise" do
        rotateOffset Clockwise (createFullCoord 0 0 10 5) `shouldEqual` createFullCoord 0 0 (-5) 10

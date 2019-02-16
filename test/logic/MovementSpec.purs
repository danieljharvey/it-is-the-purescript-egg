module Test.Logic.Movement where

import Prelude (Unit, discard, negate, ($), (*))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions
import Data.Maybe (fromMaybe)

import Egg.Types.Board (Board)
import Egg.Types.Tile (Tile, defaultTile)
import Egg.Types.Coord (Coord(..), createCoord)
import Egg.Types.Player (Player, defaultPlayer)
import Egg.Logic.Movement (calcMoveAmount, checkFloorBelowPlayer, checkPlayerDirection, correctTileOverflow, incrementPlayerDirection, incrementPlayerFrame, playerHasMoved)
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
  describe "Movement" do
    describe "incrementPlayerFrame" do
      it "Frame does not change when play is stationary" do
        let newPlayer = incrementPlayerFrame defaultPlayer
        newPlayer.currentFrame `shouldEqual` defaultPlayer.currentFrame

      it "Wipes old direction when stopped" do
        let oldPlayer = defaultPlayer { oldDirection = createCoord 1 0 }
        incrementPlayerFrame oldPlayer `shouldEqual` defaultPlayer

      it "Decreases current frame when moving left" do
        let oldPlayer = defaultPlayer { direction = createCoord (-1) 0
                                      , currentFrame = createCurrentFrame 18
                                      }
        let newPlayer = incrementPlayerFrame oldPlayer
        getCurrentFrame newPlayer.currentFrame `shouldEqual` 17

      it "Increases current frame when moving right" do
        let oldPlayer = defaultPlayer { direction = createCoord 1 0
                                      , currentFrame = dec (createCurrentFrame 18)
                                      }
        let newPlayer = incrementPlayerFrame oldPlayer
        getCurrentFrame newPlayer.currentFrame `shouldEqual` 0

      it "Decreases current frame when moving up" do
        let oldPlayer = defaultPlayer { direction = createCoord 0 (-1)
                                      , currentFrame = createCurrentFrame 18
                                      }
        let newPlayer = incrementPlayerFrame oldPlayer
        getCurrentFrame newPlayer.currentFrame `shouldEqual` 17

      it "Increases current frame when moving down" do
        let oldPlayer = defaultPlayer { direction = createCoord 0 1
                                      , currentFrame = dec (createCurrentFrame 18)
                                      }
        let newPlayer = incrementPlayerFrame oldPlayer
        getCurrentFrame newPlayer.currentFrame `shouldEqual` 0

    describe "calcMoveAmount" do
      it "Does one" do
        calcMoveAmount 10 10 `shouldEqual` 7
      it "Does another" do
        calcMoveAmount 10 20 `shouldEqual` 15
      it "Checks that no timePassed does not break it" do
        calcMoveAmount 10 0 `shouldEqual` 0
      it "Checks that no moveSpeed does not break it" do
        calcMoveAmount 0 10 `shouldEqual` 0


    describe "calcMoveAmount" do
      it "Moves left" do
        let player = defaultPlayer { direction = createCoord (-1) 0
                                   , coords = createCoord 2 2
                                   }
        let expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetX `shouldEqual` (-1 * expectedMoveAmount)

      it "Moves right" do
        let player = defaultPlayer { direction = createCoord 1 0
                                   , coords = createCoord 2 2
                                   }
        let expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetX `shouldEqual` (expectedMoveAmount)
      
      it "Moves up" do
        let player = defaultPlayer { direction = createCoord 0 (-1)
                                   , coords = createCoord 2 2
                                   }
        let expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetY `shouldEqual` (-1 * expectedMoveAmount)
      
      it "Moves down" do
        let player = defaultPlayer { direction = createCoord 0 1
                                   , coords = createCoord 2 2
                                   }
        let expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetY `shouldEqual` (expectedMoveAmount)
      
      it "Egg with no speed stays still" do
        let player = defaultPlayer { direction = createCoord 0 1
                                   , coords = createCoord 2 2
                                   , playerType = defaultPlayer.playerType {
                                   moveSpeed = 0 }
                                   }
        let expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetY `shouldEqual` 0
      
      it "Falls downwards" do
        let player = defaultPlayer { direction = createCoord 1 0
                                   , coords = createCoord 2 2
                                   , falling = true
                                   }
        let expectedMoveAmount = calcMoveAmount player.playerType.fallSpeed 100
        let { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetY `shouldEqual` (expectedMoveAmount)

    describe "correctTileOverflow" do
       it "Overflow remains the same when within boundary" do
          let coord = Coord { x: 1, y: 0, offsetX: 75, offsetY: 0 }
          correctTileOverflow coord `shouldEqual` coord

       it "Moves right when overflowing there" do
          let coord@(Coord inner) = Coord { x: 0, y: 0, offsetX: 150, offsetY: 0 }
          correctTileOverflow coord `shouldEqual` (Coord $ inner { x = 1, offsetX = 0 })

       it "Moves left when overflowing there" do
          let coord@(Coord inner) = Coord { x: 3, y: 0, offsetX: -150, offsetY: 0 }
          correctTileOverflow coord `shouldEqual` (Coord $ inner { x = 2, offsetX = 0 })

       it "Moves up when overflowing there" do
          let coord@(Coord inner) = Coord { x: 0, y: 4, offsetX: 0, offsetY: -150 }
          correctTileOverflow coord `shouldEqual` (Coord $ inner { y = 3, offsetY = 0 })

       it "Moves down when overflowing there" do
          let coord@(Coord inner) = Coord { x: 0, y: 4, offsetX: 0, offsetY: 150 }
          correctTileOverflow coord `shouldEqual` (Coord $ inner { y = 5, offsetY = 0 })
          
    describe "checkFloorBelowPlayer" do
       it "Fall through breakable block" do
          let board = boardFromArray [ [ bgTile ], [ breakable ] ]
          let player = defaultPlayer { falling = true }
          let newPlayer = checkFloorBelowPlayer board player 
          newPlayer.falling `shouldEqual` true
       
       it "Don't fall through floor" do
          let board = boardFromArray [ [ bgTile ], [ empty ] ]
          let player = defaultPlayer { falling = true }
          let newPlayer = checkFloorBelowPlayer board player 
          newPlayer.falling `shouldEqual` false
       
       it "Non-flying players fall downwards" do
          let board = boardFromArray [ [ bgTile ], [ bgTile ] ]
          let player = defaultPlayer { falling = false }
          let newPlayer = checkFloorBelowPlayer board player 
          newPlayer.falling `shouldEqual` true

       it "Flying players don't fall through floor" do
          let board = boardFromArray [ [ bgTile ], [ bgTile ] ]
          let player = flyingPlayer { falling = true }
          let newPlayer = checkFloorBelowPlayer board player 
          newPlayer.falling `shouldEqual` false
    
    describe "playerHasMoved" do
       it "Sees we have not moved" do
          playerHasMoved defaultPlayer defaultPlayer `shouldEqual` false
       it "Sees we have moved" do
          let newPlayer = defaultPlayer { coords = createCoord 5 6 }
          playerHasMoved defaultPlayer newPlayer `shouldEqual` true
          
    describe "checkPlayerDirection" do
       it "Continues in the same direction when there are no obstacles" do
          let board = boardFromArray [ [ bgTile, bgTile, bgTile ] ]
          let player = defaultPlayer { coords    = createCoord 1 0
                                     , direction = createCoord (-1) 0
                                     }
          checkPlayerDirection board player `shouldEqual` player
      
       it "Bounces off a wall to the left" do
          let board = boardFromArray [ [ empty, bgTile, bgTile ] ]
          let player = defaultPlayer { coords    = createCoord 1 0
                                     , direction = createCoord (-1) 0
                                     }
          let expected = player { direction = createCoord 1 0 }
          checkPlayerDirection board player `shouldEqual` expected

       it "Bounces off a wall to the right" do
          let board = boardFromArray [ [ bgTile, bgTile, empty ] ]
          let player = defaultPlayer { coords    = createCoord 1 0
                                     , direction = createCoord 1 0
                                     }
          let expected = player { direction = createCoord (-1) 0 }
          checkPlayerDirection board player `shouldEqual` expected

       it "Flying player bounce off wall above" do
          let board = boardFromArray [ [ empty, bgTile, bgTile ] ]
          let player = flyingPlayer { coords    = createCoord 0 1
                                    , direction = createCoord 0 (-1)
                                    }
          let expected = player { direction = createCoord 0 1 }
          checkPlayerDirection board player `shouldEqual` expected
 
       it "Flying player bounce off floor below" do
          let board = boardFromArray [ [ empty, bgTile, bgTile ] ]
          let player = flyingPlayer { coords    = createCoord 0 1
                                    , direction = createCoord 0 1
                                    }
          let expected = player { direction = createCoord 0 (-1) }
          checkPlayerDirection board player `shouldEqual` expected

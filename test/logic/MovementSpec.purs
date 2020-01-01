module Test.Logic.Movement where

import Prelude (Unit, discard, negate, ($), (*))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions
import Data.Maybe (Maybe(..), fromMaybe)
import Egg.Types.Board (Board)
import Egg.Types.Tile (Tile, defaultTile)
import Egg.Types.Coord (Coord(..), createCoord, createFullCoord)
import Egg.Types.LastAction (LastAction(..))
import Egg.Types.Player (Player, defaultPlayer)
import Egg.Logic.Movement (correctPlayerOverflow, checkMovementTile, calcMoveAmount, checkFloorBelowPlayer, checkPlayerDirection, correctPlayerMapOverflow, correctTileOverflow, incrementPlayerDirection, incrementPlayerFrame, markPlayerIfMoved, playerHasMoved)
import Egg.Types.CurrentFrame (createCurrentFrame, dec, getCurrentFrame)
import Egg.Types.TileAction (TileAction(..))
import Matrix as Mat

bgTile :: Tile
bgTile = defaultTile { background = true, breakable = false }

breakable :: Tile
breakable = defaultTile { background = false, breakable = true }

teleport :: Tile
teleport = defaultTile { action = Teleport }

empty :: Tile
empty = defaultTile { background = false, breakable = false }

boardFromArray :: Array (Array Tile) -> Board
boardFromArray tiles = fromMaybe Mat.empty $ Mat.fromArray tiles

flyingPlayer :: Player
flyingPlayer = defaultPlayer { playerType = defaultPlayer.playerType { flying = true } }

tests :: Spec Unit
tests =
  describe "Movement" do
    describe "incrementPlayerFrame" do
      it "Frame does not change when play is stationary" do
        let
          newPlayer = incrementPlayerFrame defaultPlayer
        newPlayer.currentFrame `shouldEqual` defaultPlayer.currentFrame
      it "Wipes old direction when stopped" do
        let
          oldPlayer = defaultPlayer { oldDirection = createCoord 1 0 }
        incrementPlayerFrame oldPlayer `shouldEqual` defaultPlayer
      it "Decreases current frame when moving left" do
        let
          oldPlayer =
            defaultPlayer
              { direction = createCoord (-1) 0
              , currentFrame = createCurrentFrame 18
              }
        let
          newPlayer = incrementPlayerFrame oldPlayer
        getCurrentFrame newPlayer.currentFrame `shouldEqual` 17
      it "Increases current frame when moving right" do
        let
          oldPlayer =
            defaultPlayer
              { direction = createCoord 1 0
              , currentFrame = dec (createCurrentFrame 18)
              }
        let
          newPlayer = incrementPlayerFrame oldPlayer
        getCurrentFrame newPlayer.currentFrame `shouldEqual` 0
      it "Decreases current frame when moving up" do
        let
          oldPlayer =
            defaultPlayer
              { direction = createCoord 0 (-1)
              , currentFrame = createCurrentFrame 18
              }
        let
          newPlayer = incrementPlayerFrame oldPlayer
        getCurrentFrame newPlayer.currentFrame `shouldEqual` 17
      it "Increases current frame when moving down" do
        let
          oldPlayer =
            defaultPlayer
              { direction = createCoord 0 1
              , currentFrame = dec (createCurrentFrame 18)
              }
        let
          newPlayer = incrementPlayerFrame oldPlayer
        getCurrentFrame newPlayer.currentFrame `shouldEqual` 0
    describe "calcMoveAmount" do
      it "Does one" do
        calcMoveAmount 10 10 `shouldEqual` 31
      it "Does another" do
        calcMoveAmount 10 20 `shouldEqual` 62
      it "Checks that no timePassed does not break it" do
        calcMoveAmount 10 0 `shouldEqual` 0
      it "Checks that no moveSpeed does not break it" do
        calcMoveAmount 0 10 `shouldEqual` 0
    describe "calcMoveAmount" do
      it "Moves left" do
        let
          player =
            defaultPlayer
              { direction = createCoord (-1) 0
              , coords = createCoord 2 2
              }
        let
          expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let
          { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetX `shouldEqual` (-1 * expectedMoveAmount)
      it "Moves right" do
        let
          player =
            defaultPlayer
              { direction = createCoord 1 0
              , coords = createCoord 2 2
              }
        let
          expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let
          { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetX `shouldEqual` (expectedMoveAmount)
      it "Moves up" do
        let
          player =
            defaultPlayer
              { direction = createCoord 0 (-1)
              , coords = createCoord 2 2
              }
        let
          expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let
          { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetY `shouldEqual` (-1 * expectedMoveAmount)
      it "Moves down" do
        let
          player =
            defaultPlayer
              { direction = createCoord 0 1
              , coords = createCoord 2 2
              }
        let
          expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let
          { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetY `shouldEqual` (expectedMoveAmount)
      it "Egg with no speed stays still" do
        let
          player =
            defaultPlayer
              { direction = createCoord 0 1
              , coords = createCoord 2 2
              , playerType =
                defaultPlayer.playerType
                  { moveSpeed = 0
                  }
              }
        let
          expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let
          { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetY `shouldEqual` 0
      it "Falls downwards" do
        let
          player =
            defaultPlayer
              { direction = createCoord 1 0
              , coords = createCoord 2 2
              , falling = true
              }
        let
          expectedMoveAmount = calcMoveAmount player.playerType.fallSpeed 100
        let
          { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetY `shouldEqual` (expectedMoveAmount)
      it "Egg with no move speed still falls downwards" do
        let
          player =
            defaultPlayer
              { direction = createCoord 1 0
              , coords = createCoord 2 2
              , falling = true
              , playerType =
                defaultPlayer.playerType
                  { moveSpeed = 0
                  , fallSpeed = 20
                  }
              }
        let
          expectedMoveAmount = calcMoveAmount player.playerType.fallSpeed 100
        let
          { coords: Coord newCoords } = incrementPlayerDirection 100 player
        newCoords.offsetY `shouldEqual` (expectedMoveAmount)
    describe "correctTileOverflow" do
      it "Overflow remains the same when within boundary" do
        let
          coord = Coord { x: 1, y: 0, offsetX: 54, offsetY: 0 }
        correctTileOverflow coord `shouldEqual` coord
      it "Moves right when overflowing there" do
        let
          coord@(Coord inner) = Coord { x: 0, y: 0, offsetX: 150, offsetY: 0 }
        correctTileOverflow coord `shouldEqual` (Coord $ inner { x = 1, offsetX = 0 })
      it "Moves left when overflowing there" do
        let
          coord@(Coord inner) = Coord { x: 3, y: 0, offsetX: -150, offsetY: 0 }
        correctTileOverflow coord `shouldEqual` (Coord $ inner { x = 2, offsetX = 0 })
      it "Moves up when overflowing there" do
        let
          coord@(Coord inner) = Coord { x: 0, y: 4, offsetX: 0, offsetY: -150 }
        correctTileOverflow coord `shouldEqual` (Coord $ inner { y = 3, offsetY = 0 })
      it "Moves down when overflowing there" do
        let
          coord@(Coord inner) = Coord { x: 0, y: 4, offsetX: 0, offsetY: 150 }
        correctTileOverflow coord `shouldEqual` (Coord $ inner { y = 5, offsetY = 0 })
    describe "correctPlayerOverflow" do
      it "Resets lastAction when moving tiles" do
        let
          player = defaultPlayer { coords = createFullCoord 1 1 150 0, lastAction = Just Teleported }
        let
          newPlayer = correctPlayerOverflow player
        newPlayer.lastAction `shouldEqual` Nothing
    describe "correctPlayerMapOverflow" do
      it "Does nothing when inside map" do
        let
          testMap = boardFromArray [ [ bgTile, bgTile ], [ bgTile, bgTile ] ]
        let
          player = defaultPlayer { coords = createFullCoord 0 0 19 20 }
        let
          newPlayer = correctPlayerMapOverflow testMap player
        newPlayer.coords `shouldEqual` player.coords
      it "Corrects when off left hand side of map" do
        let
          testMap = boardFromArray [ [ bgTile, bgTile ], [ bgTile, bgTile ] ]
        let
          player = defaultPlayer { coords = createFullCoord (-1) 0 95 23 }
        let
          newPlayer = correctPlayerMapOverflow testMap player
        newPlayer.coords `shouldEqual` createFullCoord 1 0 95 23
      it "Corrects when off right hand side of map" do
        let
          testMap = boardFromArray [ [ bgTile, bgTile ], [ bgTile, bgTile ] ]
        let
          player = defaultPlayer { coords = createFullCoord 2 0 10 20 }
        let
          newPlayer = correctPlayerMapOverflow testMap player
        newPlayer.coords `shouldEqual` createFullCoord 0 0 10 20
      it "Corrects when off top of map" do
        let
          testMap = boardFromArray [ [ bgTile, bgTile ], [ bgTile, bgTile ] ]
        let
          player = defaultPlayer { coords = createFullCoord 0 (-1) 12 22 }
        let
          newPlayer = correctPlayerMapOverflow testMap player
        newPlayer.coords `shouldEqual` createFullCoord 0 1 12 22
      it "Corrects when off bottom of map" do
        let
          testMap = boardFromArray [ [ bgTile, bgTile ], [ bgTile, bgTile ] ]
        let
          player = defaultPlayer { coords = createCoord 0 2 }
        let
          newPlayer = correctPlayerMapOverflow testMap player
        newPlayer.coords `shouldEqual` createCoord 0 0
    describe "checkFloorBelowPlayer" do
      it "Fall through breakable block" do
        let
          board = boardFromArray [ [ bgTile ], [ breakable ] ]
        let
          player = defaultPlayer { falling = true }
        let
          newPlayer = checkFloorBelowPlayer board player
        newPlayer.falling `shouldEqual` true
      it "Don't fall through floor" do
        let
          board = boardFromArray [ [ bgTile ], [ empty ] ]
        let
          player = defaultPlayer { falling = true }
        let
          newPlayer = checkFloorBelowPlayer board player
        newPlayer.falling `shouldEqual` false
      it "Non-flying players fall downwards" do
        let
          board = boardFromArray [ [ bgTile ], [ bgTile ] ]
        let
          player = defaultPlayer { falling = false }
        let
          newPlayer = checkFloorBelowPlayer board player
        newPlayer.falling `shouldEqual` true
      it "Flying players don't fall through floor" do
        let
          board = boardFromArray [ [ bgTile ], [ bgTile ] ]
        let
          player = flyingPlayer { falling = true }
        let
          newPlayer = checkFloorBelowPlayer board player
        newPlayer.falling `shouldEqual` false
    describe "playerHasMoved" do
      it "Sees we have not moved" do
        playerHasMoved defaultPlayer defaultPlayer `shouldEqual` false
      it "Sees we have moved" do
        let
          newPlayer = defaultPlayer { coords = createCoord 5 6 }
        playerHasMoved defaultPlayer newPlayer `shouldEqual` true
    describe "markPlayerIfMoved" do
      it "Sees we have not moved" do
        let
          newPlayer = markPlayerIfMoved defaultPlayer defaultPlayer
        newPlayer.moved `shouldEqual` false
      it "Sees we have moved" do
        let
          newPlayer = defaultPlayer { coords = createCoord 5 6 }
        let
          movedPlayer = markPlayerIfMoved defaultPlayer newPlayer
        movedPlayer.moved `shouldEqual` true
    describe "checkPlayerDirection" do
      it "Continues in the same direction when there are no obstacles" do
        let
          board = boardFromArray [ [ bgTile, bgTile, bgTile ] ]
        let
          player =
            defaultPlayer
              { coords = createCoord 1 0
              , direction = createCoord (-1) 0
              }
        checkPlayerDirection board player `shouldEqual` player
      it "Bounces off a wall to the left" do
        let
          board = boardFromArray [ [ empty, bgTile, bgTile ] ]
        let
          player =
            defaultPlayer
              { coords = createCoord 1 0
              , direction = createCoord (-1) 0
              }
        let
          expected = player { direction = createCoord 1 0 }
        checkPlayerDirection board player `shouldEqual` expected
      it "Does not bounce off a wall to the left when falling" do
        let
          board = boardFromArray [ [ empty, bgTile, bgTile ] ]
        let
          player =
            defaultPlayer
              { coords = createCoord 1 0
              , direction = createCoord (-1) 0
              , falling = true
              }
        checkPlayerDirection board player `shouldEqual` player
      it "Bounces off a wall to the right" do
        let
          board = boardFromArray [ [ bgTile, bgTile, empty ] ]
        let
          player =
            defaultPlayer
              { coords = createCoord 1 0
              , direction = createCoord 1 0
              }
        let
          expected = player { direction = createCoord (-1) 0 }
        checkPlayerDirection board player `shouldEqual` expected
      it "Flying player bounce off wall above" do
        let
          board = boardFromArray [ [ empty, bgTile, bgTile ] ]
        let
          player =
            flyingPlayer
              { coords = createCoord 0 1
              , direction = createCoord 0 (-1)
              }
        let
          expected = player { direction = createCoord 0 1 }
        checkPlayerDirection board player `shouldEqual` expected
      it "Flying player bounce off floor below" do
        let
          board = boardFromArray [ [ empty, bgTile, bgTile ] ]
        let
          player =
            flyingPlayer
              { coords = createCoord 0 1
              , direction = createCoord 0 1
              }
        let
          expected = player { direction = createCoord 0 (-1) }
        checkPlayerDirection board player `shouldEqual` expected
    describe "checkMovementTile" do
      it "Does nothing on normal tile" do
        let
          board = boardFromArray [ [ empty, empty ] ]

          player = defaultPlayer { coords = createCoord 0 0 }
        checkMovementTile board player `shouldEqual` player
      it "Stays in place when only one teleport" do
        let
          board = boardFromArray [ [ teleport, empty ] ]

          player = defaultPlayer { coords = createCoord 0 0 }
        checkMovementTile board player `shouldEqual` player
      it "Moves to other teleport tile" do
        let
          board = boardFromArray [ [ teleport, teleport ] ]

          player = defaultPlayer { coords = createCoord 0 0 }

          expectedPlayer = defaultPlayer { coords = createCoord 1 0, lastAction = Just Teleported }
        checkMovementTile board player `shouldEqual` expectedPlayer
      it "Does not move when last action was teleports" do
        let
          board = boardFromArray [ [ teleport, teleport ] ]

          player =
            defaultPlayer
              { coords = createCoord 0 0
              , lastAction = (Just Teleported)
              }
        checkMovementTile board player `shouldEqual` player

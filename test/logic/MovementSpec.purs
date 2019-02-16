module Test.Logic.Movement where

import Prelude (Unit, discard, negate, ($), (*))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions
import Data.Maybe (fromMaybe)

import Egg.Types.Tile (defaultTile)
import Egg.Types.Coord (createCoord)
import Egg.Types.Player (defaultPlayer)
import Egg.Logic.Movement (calcMoveAmount, correctTileOverflow, incrementPlayerDirection, incrementPlayerFrame, checkFloorBelowPlayer) 
import Egg.Types.CurrentFrame (createCurrentFrame, dec, getCurrentFrame)

import Matrix as Mat

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
        let newPlayer = incrementPlayerDirection 100 player
        newPlayer.coords.offsetX `shouldEqual` (-1 * expectedMoveAmount)

      it "Moves right" do
        let player = defaultPlayer { direction = createCoord 1 0
                                   , coords = createCoord 2 2
                                   }
        let expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let newPlayer = incrementPlayerDirection 100 player
        newPlayer.coords.offsetX `shouldEqual` (expectedMoveAmount)
      
      it "Moves up" do
        let player = defaultPlayer { direction = createCoord 0 (-1)
                                   , coords = createCoord 2 2
                                   }
        let expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let newPlayer = incrementPlayerDirection 100 player
        newPlayer.coords.offsetY `shouldEqual` (-1 * expectedMoveAmount)
      
      it "Moves down" do
        let player = defaultPlayer { direction = createCoord 0 1
                                   , coords = createCoord 2 2
                                   }
        let expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let newPlayer = incrementPlayerDirection 100 player
        newPlayer.coords.offsetY `shouldEqual` (expectedMoveAmount)
      
      it "Egg with no speed stays still" do
        let player = defaultPlayer { direction = createCoord 0 1
                                   , coords = createCoord 2 2
                                   , playerType = defaultPlayer.playerType {
                                   moveSpeed = 0 }
                                   }
        let expectedMoveAmount = calcMoveAmount player.playerType.moveSpeed 100
        let newPlayer = incrementPlayerDirection 100 player
        newPlayer.coords.offsetY `shouldEqual` 0
    
    describe "correctTileOverflow" do
       it "Overflow remains the same when within boundary" do
          let coord = { x: 1, y: 0, offsetX: 75, offsetY: 0 }
          correctTileOverflow coord `shouldEqual` coord

       it "Moves right when overflowing there" do
          let coord = { x: 0, y: 0, offsetX: 150, offsetY: 0 }
          correctTileOverflow coord `shouldEqual` coord { x = 1, offsetX = 0 }

       it "Moves left when overflowing there" do
          let coord = { x: 3, y: 0, offsetX: -150, offsetY: 0 }
          correctTileOverflow coord `shouldEqual` coord { x = 2, offsetX = 0 }

       it "Moves up when overflowing there" do
          let coord = { x: 0, y: 4, offsetX: 0, offsetY: -150 }
          correctTileOverflow coord `shouldEqual` coord { y = 3, offsetY = 0 }

       it "Moves down when overflowing there" do
          let coord = { x: 0, y: 4, offsetX: 0, offsetY: 150 }
          correctTileOverflow coord `shouldEqual` coord { y = 5, offsetY = 0 }

    describe "checkFloorBelowPlayer" do
       it "Fall through breakable block" do
          let bgTile = defaultTile { background = true, breakable = false }
          let fgTile = defaultTile { background = false, breakable = true }
          let board = fromMaybe Mat.empty $ Mat.fromArray [ [ bgTile ], [ fgTile ] ]
          let player = defaultPlayer { falling = true }
          let newPlayer = checkFloorBelowPlayer board player 
          newPlayer.falling `shouldEqual` true
       
       it "Don't fall through floor" do
          let bgTile = defaultTile { background = true, breakable = false }
          let fgTile = defaultTile { background = false, breakable = false }
          let board = fromMaybe Mat.empty $ Mat.fromArray [ [ bgTile ], [ fgTile ] ]
          let player = defaultPlayer { falling = true }
          let newPlayer = checkFloorBelowPlayer board player 
          newPlayer.falling `shouldEqual` false
       
       it "Non-flying players fall downwards" do
          let bgTile = defaultTile { background = true, breakable = false }
          let board = fromMaybe Mat.empty $ Mat.fromArray [ [ bgTile ], [ bgTile ] ]
          let player = defaultPlayer { falling = false }
          let newPlayer = checkFloorBelowPlayer board player 
          newPlayer.falling `shouldEqual` true

       it "Flying players don't fall through floor" do
          let bgTile = defaultTile { background = true, breakable = false }
          let board = fromMaybe Mat.empty $ Mat.fromArray [ [ bgTile ], [ bgTile ] ]
          let player = defaultPlayer 
                { falling = true
                , playerType = defaultPlayer.playerType { flying = true }
                }
          let newPlayer = checkFloorBelowPlayer board player 
          newPlayer.falling `shouldEqual` false

{-

test("Check player has not moved", () => {
  const oldPlayer = new Player({
    coords: new Coords({ x: 0, y: 0 })
  });

  const newPlayer = oldPlayer.modify({ id: 3 });

  const moved = Movement.playerHasMoved(oldPlayer, newPlayer);

  expect(moved).toEqual(false);
});

test("Check player has moved", () => {
  const oldPlayer = new Player({
    coords: new Coords({ x: 0, y: 0, offsetX: 3 })
  });

  const newPlayer = oldPlayer.modify({
    coords: oldPlayer.coords.modify({ offsetX: 0 })
  });

  const moved = Movement.playerHasMoved(oldPlayer, newPlayer);

  expect(moved).toEqual(true);
});

test("Don't bounce off anything", () => {
  const boardArray = [
    [new Tile({ background: true })],
    [new Tile({ background: true })],
    [new Tile({ background: true })]
  ];

  const board = new Board(boardArray);

  const player = new Player({
    coords: new Coords({
      x: 1,
      y: 0
    }),
    direction: new Coords({
      x: -1
    })
  });

  const result = Movement.checkPlayerDirection(board)(player);

  expect(result.equals(player)).toEqual(true);
});

test("Bounce off a wall to the left", () => {
  const boardArray = [
    [new Tile({ background: false })],
    [new Tile({ background: true })],
    [new Tile({ background: true })]
  ];

  const board = new Board(boardArray);

  const player = new Player({
    coords: new Coords({
      x: 1,
      y: 0
    }),
    direction: new Coords({
      x: -1
    })
  });

  const expected = player.modify({
    direction: new Coords({
      x: 1
    })
  });

  const result = Movement.checkPlayerDirection(board)(player);

  expect(result.equals(expected)).toEqual(true);
});

test("Bounce off a wall to the right", () => {
  const boardArray = [
    [new Tile({ background: true, breakable: false })],
    [new Tile({ background: true, breakable: false })],
    [new Tile({ background: false, breakable: false })]
  ];

  const board = new Board(boardArray);

  const player = new Player({
    coords: new Coords({
      x: 1,
      y: 0
    }),
    direction: new Coords({
      x: 1
    })
  });

  const expected = player.modify({
    direction: new Coords({
      x: -1
    })
  });

  const result = Movement.checkPlayerDirection(board)(player);

  expect(result.equals(expected)).toEqual(true);
});

test("Flying player bounce off wall above", () => {
  const boardArray = [
    [
      new Tile({ background: false, breakable: false }),
      new Tile({ background: true, breakable: false }),
      new Tile({ background: true, breakable: false })
    ]
  ];

  const board = new Board(boardArray);

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 1
    }),
    direction: new Coords({
      y: -1
    }),
    flying: true
  });

  const expected = player.modify({
    direction: new Coords({
      x: 1,
      y: 0
    })
  });

  const result = Movement.checkPlayerDirection(board)(player);

  expect(result.equals(expected)).toEqual(true);
});

test("Flying player bounce off right", () => {
  const boardArray = [
    [new Tile({ background: true, breakable: false })],
    [new Tile({ background: true, breakable: false })],
    [new Tile({ background: false, breakable: false })]
  ];

  const board = new Board(boardArray);

  const player = new Player({
    coords: new Coords({
      x: 1,
      y: 0
    }),
    direction: new Coords({
      x: 1
    }),
    flying: true
  });

  const expected = player.modify({
    direction: new Coords({
      x: 0,
      y: 1
    })
  });

  const result = Movement.checkPlayerDirection(board)(player);

  expect(result.equals(expected)).toEqual(true);
});

test("Flying player bounce off wall below", () => {
  const boardArray = [
    [
      new Tile({ background: true, breakable: false }),
      new Tile({ background: true, breakable: false }),
      new Tile({ background: false, breakable: false })
    ]
  ];

  const board = new Board(boardArray);

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 1
    }),
    direction: new Coords({
      y: 1
    }),
    flying: true
  });

  const expected = player.modify({
    direction: new Coords({
      x: -1,
      y: 0
    })
  });

  const result = Movement.checkPlayerDirection(board)(player);

  expect(result.equals(expected)).toEqual(true);
});

test("Flying player bounce off left", () => {
  const boardArray = [
    [new Tile({ background: false })],
    [new Tile({ background: true })],
    [new Tile({ background: true })]
  ];

  const board = new Board(boardArray);

  const player = new Player({
    coords: new Coords({
      x: 1,
      y: 0
    }),
    direction: new Coords({
      x: -1
    }),
    flying: true
  });

  const expected = player.modify({
    direction: new Coords({
      x: 0,
      y: -1
    })
  });

  const result = Movement.checkPlayerDirection(board)(player);

  expect(result.equals(expected)).toEqual(true);
});


-}

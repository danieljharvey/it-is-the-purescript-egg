module Test.Logic.Movement where

import Prelude (Unit, discard, negate)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions

import Egg.Types.Coord (createCoord)
import Egg.Types.Player (defaultPlayer)
import Egg.Logic.Movement (incrementPlayerFrame)
import Egg.Types.CurrentFrame (createCurrentFrame, dec, getCurrentFrame)

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
{-


test("Move left", () => {
  const player = new Player({
    direction: new Coords({
      x: -1
    }),
    coords: new Coords({
      x: 2,
      y: 2
    })
  });

  const timePassed = 10;
  const moveAmount = Movement.calcMoveAmount(player.moveSpeed, timePassed);

  const expected = player.modify({
    coords: player.coords.modify({
      offsetX: -moveAmount
    })
  });

  const response = Movement.incrementPlayerDirection(timePassed)(player);
  expect(response).toEqual(expected);
});

test("Move right", () => {
  const player = new Player({
    direction: new Coords({
      x: 1
    }),
    coords: new Coords({
      x: 2,
      y: 2
    })
  });

  const timePassed = 10;
  const moveAmount = Movement.calcMoveAmount(player.moveSpeed, timePassed);

  const expected = player.modify({
    coords: player.coords.modify({
      offsetX: moveAmount
    })
  });

  const response = Movement.incrementPlayerDirection(timePassed)(player);
  expect(response).toEqual(expected);
});

test("Move up", () => {
  const player = new Player({
    direction: new Coords({
      y: -1
    }),
    coords: new Coords({
      x: 2,
      y: 2
    })
  });

  const timePassed = 10;
  const moveAmount = Movement.calcMoveAmount(player.moveSpeed, timePassed);

  const expected = player.modify({
    coords: player.coords.modify({
      offsetY: -moveAmount
    })
  });

  const response = Movement.incrementPlayerDirection(timePassed)(player);
  expect(response).toEqual(expected);
});

test("Move down", () => {
  const player = new Player({
    direction: new Coords({
      y: 1
    }),
    coords: new Coords({
      x: 2,
      y: 2
    })
  });

  const timePassed = 10;
  const moveAmount = Movement.calcMoveAmount(player.moveSpeed, timePassed);

  const expected = player.modify({
    coords: player.coords.modify({
      offsetY: moveAmount
    })
  });

  const response = Movement.incrementPlayerDirection(timePassed)(player);
  expect(response).toEqual(expected);
});




test("Calculate move amount", () => {
  const player = new Player();
  expect(Movement.calcMoveAmount(10, 10)).toEqual(5);
  expect(Movement.calcMoveAmount(10, 20)).toEqual(10);
});

test("Egg with no speed stays still", () => {
  const player = new Player({
    moveSpeed: 0
  });
  const movedPlayer = Movement.incrementPlayerDirection(1)(player);

  const oldCoords = player.coords;
  const newCoords = movedPlayer.coords;

  expect(oldCoords.equals(newCoords)).toEqual(true);
});

test("Overflow remains the same", () => {
  const coords = new Coords({ x: 1, y: 0, offsetX: 75, offsetY: 0 });

  const fixedCoords = Movement.correctTileOverflow(coords);

  expect(fixedCoords.x).toEqual(1);
  expect(fixedCoords.offsetX).toEqual(75);
});

test("No overflow to right", () => {
  const coords = new Coords({ x: 0, y: 0, offsetX: 100, offsetY: 0 });

  const fixedCoords = Movement.correctTileOverflow(coords);

  expect(fixedCoords.x).toEqual(1);
  expect(fixedCoords.offsetX).toEqual(0);
});

test("No overflow to left", () => {
  const coords = new Coords({ x: 3, y: 0, offsetX: -100, offsetY: 0 });

  const fixedCoords = Movement.correctTileOverflow(coords);

  expect(fixedCoords.x).toEqual(2);
  expect(fixedCoords.offsetX).toEqual(0);
});

test("No overflow above", () => {
  const coords = new Coords({ x: 0, y: 4, offsetX: 0, offsetY: -100 });

  const fixedCoords = Movement.correctTileOverflow(coords);

  expect(fixedCoords.y).toEqual(3);
  expect(fixedCoords.offsetY).toEqual(0);
});

test("No overflow below", () => {
  const coords = new Coords({ x: 0, y: 4, offsetX: 0, offsetY: 100 });

  const fixedCoords = Movement.correctTileOverflow(coords);

  expect(fixedCoords.y).toEqual(5);
  expect(fixedCoords.offsetY).toEqual(0);
});

test("Fall through breakable block", () => {
  const boardArray = [
    [
      new Tile({ background: true, breakable: false }),
      new Tile({ background: false, breakable: true })
    ]
  ];

  const board = new Board(boardArray);

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0
    }),
    falling: true
  });

  const result = Movement.checkFloorBelowPlayer(board, 10)(player);

  expect(result.equals(player)).toEqual(true);
  expect(result.falling).toEqual(true);
});

test("Don't fall through floor", () => {
  const boardArray = [
    [
      new Tile({ background: true, breakable: false }),
      new Tile({ background: false, breakable: false })
    ]
  ];

  const board = new Board(boardArray);

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0
    }),
    falling: true
  });

  const expected = player.modify({
    falling: false
  });

  const result = Movement.checkFloorBelowPlayer(board, 10)(player);

  expect(result.equals(expected)).toEqual(true);
  expect(result.falling).toEqual(false);
});

test("Non-flying players fall downwards", () => {
  const boardArray = [
    [new Tile({ background: true }), new Tile({ background: true })]
  ];

  const board = new Board(boardArray);

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0
    }),
    falling: false
  });

  const expected = player.modify({
    falling: true
  });

  const result = Movement.checkFloorBelowPlayer(board, 10)(player);

  expect(result.equals(expected)).toEqual(true);
  expect(result.falling).toEqual(true);
});

test("Flying players don't fall through floor", () => {
  const boardArray = [
    [
      new Tile({ background: true, breakable: false }),
      new Tile({ background: true, breakable: false })
    ]
  ];

  const board = new Board(boardArray);

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0
    }),
    flying: true,
    falling: true
  });

  const expected = player.modify({
    falling: false // flying players are never falling
  });

  const result = Movement.checkFloorBelowPlayer(board, 10)(player);

  expect(result.equals(expected)).toEqual(true);
  expect(result.falling).toEqual(false);
});

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

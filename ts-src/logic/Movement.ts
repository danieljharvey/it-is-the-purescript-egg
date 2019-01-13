import * as _ from "ramda";

import { Board } from "../objects/Board";
import { BoardSize } from "../objects/BoardSize";
import { Coords } from "../objects/Coords";
import { GameState } from "../objects/GameState";
import { Player } from "../objects/Player";

import { Jetpack } from "../Jetpack";

import * as Map from "./Map";
import * as PathFinder from "./PathFinder";
import { RenderMap } from "./RenderMap";

import { Renderer } from "../dom/Renderer";

import { fromJS, is, List } from "immutable";

const OFFSET_DIVIDE: number = 100;

// doCalcs takes the current map, the current players, and returns new player objects

// loop through passed players[] array, do changes, return new one
export const doCalcs = (
  gameState: GameState,
  timePassed: number
): GameState => {
  const playerCalcs = doPlayerCalcs(
    gameState.board,
    timePassed,
    gameState.players
  );
  return gameState.modify({
    players: gameState.players.map(playerCalcs)
  });
};

export const calcMoveAmount = (
  moveSpeed: number,
  timePassed: number
): number => {
  const moveAmount: number = 1 / OFFSET_DIVIDE * moveSpeed * 5;
  const frameRateAdjusted: number = moveAmount * timePassed;
  if (isNaN(frameRateAdjusted)) {
    return 0;
  }
  return frameRateAdjusted;
};

export const correctTileOverflow = (coords: Coords): Coords => {
  if (coords.offsetX >= OFFSET_DIVIDE) {
    // move one tile to right
    return coords.modify({
      offsetX: 0,
      x: coords.x + 1
    });
  }

  if (coords.offsetX <= -1 * OFFSET_DIVIDE) {
    // move one tile to left
    return coords.modify({
      offsetX: 0,
      x: coords.x - 1
    });
  }

  if (coords.offsetY >= OFFSET_DIVIDE) {
    // move one tile down
    return coords.modify({
      offsetY: 0,
      y: coords.y + 1
    });
  }

  if (coords.offsetY <= -1 * OFFSET_DIVIDE) {
    // move one tile up
    return coords.modify({
      offsetY: 0,
      y: coords.y - 1
    });
  }

  return coords;
};

// only public so it can be tested, please don't use outside of here
export const checkFloorBelowPlayer = (board: Board, timePassed: number) => (
  player: Player
): Player => {
  if (player.coords.offsetX !== 0) {
    return player;
  }

  if (player.flying === true) {
    return player.modify({
      falling: false
    });
  }

  const coords = player.coords;

  const belowCoords = Map.correctForOverflow(
    board,
    coords.modify({ y: coords.y + 1 })
  );

  const tile = board.getTile(belowCoords.x, belowCoords.y);

  if (tile.background) {
    // gap below, start falling down it
    return player.modify({
      falling: true
    });
  }

  if (tile.get("breakable") === true && player.falling) {
    return player; // allow player to keep falling through breakable tile
  }

  // solid ground, stop falling
  return player.modify({
    falling: false
  });
};

// curry and compose together a nice pipeline function to transform old player state into new
export const getCalcFunction = (
  oldPlayer: Player,
  board: Board,
  timePassed: number,
  players: Player[]
) => {
  // separated as not all functions will be the same for enemies
  const playerSpecific = getPlayerSpecificMoves(
    oldPlayer,
    board,
    timePassed,
    players
  );

  return _.compose(
    markPlayerAsMoved(oldPlayer),
    checkForMovementTiles(board),
    correctPlayerOverflow(board),
    playerSpecific,
    incrementPlayerFrame
  );
};

export const getPlayerSpecificMoves = (
  player: Player,
  board: Board,
  timePassed: number,
  players: Player[]
) => {
  if (player.movePattern === "seek-egg") {
    return getSeekEggMoves(player, board, timePassed, players);
  }
  return getEggMoves(player, board, timePassed);
};

export const getEggMoves = (
  oldPlayer: Player,
  board: Board,
  timePassed: number
) => {
  return _.compose(
    incrementPlayerDirection(timePassed),
    checkPlayerDirection(board),
    checkFloorBelowPlayer(board, timePassed)
  );
};

export const getSeekEggMoves = (
  oldPlayer: Player,
  board: Board,
  timePassed: number,
  players: Player[]
) => {
  return _.compose(
    incrementPlayerDirection(timePassed),
    checkPlayerDirection(board),
    pathFinding(board, players)
  );
};

// decide on next direction to follow based on closest egg to chase
export const pathFinding = (board: Board, players: Player[]) => (
  player: Player
) => {
  // only move when at actual place
  if (player.coords.offsetX !== 0 || player.coords.offsetY !== 0) {
    return player;
  }
  const pathMap = RenderMap.createPathFindingMapFromBoard(board);
  const maybe = PathFinder.findClosestPath(pathMap)(player.coords)(
    getAllCoords(players)
  );

  return maybe.map(PathFinder.findNextDirection).caseOf({
    just: val =>
      player.modify({
        direction: new Coords(val)
      }),
    nothing: () => player
  });
};

const getAllCoords = (players: Player[]): List<Coords> => {
  return fromJS(
    players
      .filter(player => {
        return player.value > 0;
      })
      .map(player => {
        return player.coords;
      })
  );
};

export const doPlayerCalcs = (
  board: Board,
  timePassed: number,
  players: Player[]
) => (player: Player): Player =>
  getCalcFunction(player, board, timePassed, players)(player);

// work out whether player's location has moved since last go
export const markPlayerAsMoved = (oldPlayer: Player) => (
  newPlayer: Player
): Player => {
  return newPlayer.modify({
    moved: playerHasMoved(oldPlayer, newPlayer)
  });
};

// works out whether Player has actually moved since last go
// used to decide whether to do an action to stop static players hitting switches infinitely etc
export const playerHasMoved = (
  oldPlayer: Player,
  newPlayer: Player
): boolean => {
  return !is(oldPlayer.coords, newPlayer.coords);
};

export const checkForMovementTiles = (board: Board) => (
  player: Player
): Player => {
  const currentCoords = player.coords;

  if (currentCoords.offsetX !== 0 || currentCoords.offsetY !== 0) {
    return player;
  }

  const coords = Map.correctForOverflow(board, currentCoords);

  const tile = board.getTile(coords.x, coords.y);

  if (tile.action === "teleport") {
    return teleport(board)(player);
  }

  return player;
};

// find another teleport and go to it
// if no others, do nothing
export const teleport = (board: Board) => (player: Player): Player => {
  if (player.lastAction === "teleport") {
    return player;
  }
  const newTile = Map.findTile(board, player.coords, 14);
  if (newTile) {
    return player.modify({
      coords: player.coords.modify({
        x: newTile.x,
        y: newTile.y
      }),
      lastAction: "teleport"
    });
  }
  return player;
};

export const incrementPlayerFrame = (player: Player): Player => {
  if (
    player.direction.x === 0 &&
    player.oldDirection.x === 0 &&
    player.direction.y === 0 &&
    player.oldDirection.y === 0 &&
    player.currentFrame === 0
  ) {
    // we are still, as it should be
    return player;
  }

  if (
    player.direction.x === 0 &&
    player.direction.y === 0 &&
    player.currentFrame === 0
  ) {
    // if we're still, and have returned to main frame, disregard old movement
    return player.modify({
      oldDirection: new Coords()
    });
  }

  let newFrame = player.currentFrame;

  // if going left, reduce frame
  if (
    player.direction.x < 0 ||
    player.oldDirection.x < 0 ||
    player.direction.y < 0 ||
    player.oldDirection.y < 0
  ) {
    newFrame = player.currentFrame - 1;
    if (newFrame < 0) {
      newFrame = player.frames - 1;
    }
  }

  // if going right, increase frame
  if (
    player.direction.x > 0 ||
    player.oldDirection.x > 0 ||
    player.direction.y > 0 ||
    player.oldDirection.y > 0
  ) {
    newFrame = player.currentFrame + 1;
    if (newFrame >= player.frames) {
      newFrame = 0;
    }
  }

  return player.modify({
    currentFrame: newFrame
  });
};

export const checkPlayerDirection = (board: Board) => (
  player: Player
): Player => {
  return player.flying === true
    ? checkFlyingPlayerDirection(board)(player)
    : checkStandardPlayerDirection(board)(player);
};

export const checkFlyingPlayerDirection = (board: Board) => (
  player: Player
): Player => {
  const coords = player.coords;

  if (player.direction.y < 0) {
    if (!Map.checkTileIsEmpty(board, coords.x, coords.y - 1)) {
      // turn around
      return player.modify({
        coords: coords.modify({
          offsetY: 0
        }),
        direction: player.direction.modify({
          x: 1,
          y: 0
        }),
        stop: false
      });
    }
  }

  if (player.direction.y > 0) {
    if (!Map.checkTileIsEmpty(board, coords.x, coords.y + 1)) {
      // turn around
      return player.modify({
        coords: coords.modify({
          offsetY: 0
        }),
        direction: player.direction.modify({
          x: -1,
          y: 0
        }),
        stop: false
      });
    }
  }

  if (player.direction.x < 0) {
    if (!Map.checkTileIsEmpty(board, coords.x - 1, coords.y)) {
      // turn around
      return player.modify({
        coords: coords.modify({
          offsetX: 0
        }),
        direction: player.direction.modify({
          x: 0,
          y: -1
        }),
        stop: false
      });
    }
  }

  if (player.direction.x > 0) {
    if (!Map.checkTileIsEmpty(board, coords.x + 1, coords.y)) {
      // turn around
      return player.modify({
        coords: coords.modify({
          offsetX: 0
        }),
        direction: player.direction.modify({
          x: 0,
          y: 1
        }),
        stop: false
      });
    }
  }

  return player.modify({
    stop: false
  });
};
// this checks whether the next place we intend to go is a goddamn trap, and changes direction if so
export const checkStandardPlayerDirection = (board: Board) => (
  player: Player
): Player => {
  const coords = player.coords;

  if (player.direction.x !== 0 && player.falling === false) {
    if (
      !Map.checkTileIsEmpty(board, coords.x - 1, coords.y) &&
      !Map.checkTileIsEmpty(board, coords.x + 1, coords.y)
    ) {
      return player.modify({
        stop: true // don't go on this turn
      });
    }
  }

  if (player.direction.x < 0 && player.falling === false) {
    if (!Map.checkTileIsEmpty(board, coords.x - 1, coords.y)) {
      // turn around
      return player.modify({
        coords: coords.modify({
          offsetX: 0
        }),
        direction: player.direction.modify({
          x: 1
        }),
        stop: false
      });
    }
  }

  if (player.direction.x > 0 && player.falling === false) {
    if (!Map.checkTileIsEmpty(board, coords.x + 1, coords.y)) {
      // turn around
      return player.modify({
        coords: coords.modify({
          offsetX: 0
        }),
        direction: player.direction.modify({
          x: -1
        }),
        stop: false
      });
    }
  }

  return player.modify({
    stop: false
  });
};

// this does the left/right moving, but does not care if walls are there as that is the responsibility of checkPlayerDirection
export const incrementPlayerDirection = (timePassed: number) => (
  player: Player
): Player => {
  // falling is priority - do this if a thing
  if (player.falling) {
    const fallAmount: number = calcMoveAmount(player.fallSpeed, timePassed);
    const newOffsetY = player.coords.offsetX + fallAmount;
    const newCoords = player.coords.modify({
      offsetY: player.coords.offsetY + fallAmount
    });
    return player.modify({
      coords: newCoords
    });
  }

  if (player.moveSpeed === 0 || player.stop !== false) {
    // we are still, no need for movement
    return player;
  }

  const moveAmount = calcMoveAmount(player.moveSpeed, timePassed);

  const coords = player.coords;

  // X axis movement

  if (player.direction.x < 0) {
    // move left
    const newOffsetX = coords.offsetX - moveAmount;
    return player.modify({
      coords: coords.modify({
        offsetX: newOffsetX
      })
    });
  } else if (player.direction.x > 0) {
    // move right
    const newOffsetX = coords.offsetX + moveAmount;

    return player.modify({
      coords: coords.modify({
        offsetX: newOffsetX
      })
    });
  }

  // if we've stopped and ended up not quite squared up, correct this
  if (player.direction.x === 0) {
    if (coords.offsetX > 0) {
      // shuffle left
      const newOffsetX = coords.offsetX - moveAmount;

      return player.modify({
        coords: coords.modify({
          offsetX: newOffsetX
        })
      });
    } else if (coords.offsetX < 0) {
      // shuffle right
      const newOffsetX = coords.offsetX + moveAmount;

      return player.modify({
        coords: coords.modify({
          offsetX: newOffsetX
        })
      });
    }
  }

  // Y axis movement

  if (player.direction.y < 0) {
    // move up
    const newOffsetY = coords.offsetY - moveAmount;
    return player.modify({
      coords: coords.modify({
        offsetY: newOffsetY
      })
    });
  } else if (player.direction.y > 0) {
    // move down
    const newOffsetY = coords.offsetY + moveAmount;

    return player.modify({
      coords: coords.modify({
        offsetY: newOffsetY
      })
    });
  }

  // if we've stopped and ended up not quite squared up, correct this
  if (player.direction.y === 0) {
    if (coords.offsetY > 0) {
      // shuffle up
      const newOffsetY = coords.offsetY - moveAmount;

      return player.modify({
        coords: coords.modify({
          offsetY: newOffsetY
        })
      });
    } else if (coords.offsetY < 0) {
      // shuffle down
      const newOffsetY = coords.offsetY + moveAmount;

      return player.modify({
        coords: coords.modify({
          offsetY: newOffsetY
        })
      });
    }
  }

  // do nothing, return same object
  return player;
};

export const correctPlayerOverflow = (board: Board) => (
  player: Player
): Player => {
  const newCoords = this.correctTileOverflow(player.coords);
  const loopedCoords = Map.correctForOverflow(board, newCoords);

  if (
    loopedCoords.x !== player.coords.x ||
    loopedCoords.y !== player.coords.y
  ) {
    // if we've actually moved, then
    return player.modify({
      coords: loopedCoords,
      lastAction: ""
    });
  }

  // else
  return player.modify({
    coords: loopedCoords
  });
};

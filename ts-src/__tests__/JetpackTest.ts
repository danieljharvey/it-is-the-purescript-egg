import { Jetpack } from "../Jetpack";

import { Board } from "../objects/Board";
import { Coords } from "../objects/Coords";
import { Player } from "../objects/Player";
import { Tile } from "../objects/Tile";

// create a board with 4 tiles, one of which will create a player
const createPlayerBoard = () => {
  const topLeftTile = new Tile({
    collectable: 0,
    x: 0,
    y: 0
  });

  const topRightTile = topLeftTile.modify({
    x: 1
  });

  const bottomLeftTile = topLeftTile.modify({
    y: 1
  });

  const createPlayerTile = new Tile({
    createPlayer: "red-egg",
    x: 1,
    y: 1
  });

  const array = [
    [topLeftTile, bottomLeftTile],
    [topRightTile, createPlayerTile]
  ];

  return new Board(array);
};

test("Create new player", () => {

  const coords = new Coords({ x: 1, y: 1 });

  const type = "red-egg";

  const direction = new Coords({
    x: 1,
    y: 0
  })

  const jetpack = new Jetpack();

  const player = jetpack.createNewPlayer(type, coords, direction);

  expect(typeof player).toEqual("object");
  expect(player.coords).toEqual(coords);
  expect(player.direction).toEqual(direction);
});

test("Filter create tiles", () => {
  const board = createPlayerBoard();

  const tiles = board.getAllTiles();

  const jetpack = new Jetpack();

  const filtered = jetpack.filterCreateTiles(tiles);

  expect(filtered.size).toEqual(1);
});

test("Create multiple new players", () => {

  const board = createPlayerBoard();

  const jetpack = new Jetpack();
  jetpack.nextPlayerID = 3;
  jetpack.moveSpeed = 10;

  const expected = new Player({
    coords: new Coords({ x: 1, y: 1 }),
    direction: new Coords({ x: 1 }),
    id: 0,
    multiplier: 2,
    frames: 18,
    type: "red-egg",
    value: 2,
    moveSpeed: 10,
    fallSpeed: 15,
    img: "egg-sprite-red.png",
    title: "It is of course the red egg"
  });

  const players = jetpack.createPlayers(board);

  expect(typeof players).toEqual("object");
  expect(players.first()).toEqual(expected);
});

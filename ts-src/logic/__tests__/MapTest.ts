import { Board } from "../../objects/Board";
import { BoardSize } from "../../objects/BoardSize";
import { Coords } from "../../objects/Coords";

import * as Map from "../../logic/Map";

test("Translate rotation", () => {
  const rotateData = [
    { inX: 0, inY: 0, clockwise: true, outX: 9, outY: 0 },
    { inX: 9, inY: 0, clockwise: true, outX: 9, outY: 9 },
    { inX: 9, inY: 9, clockwise: true, outX: 0, outY: 9 },
    { inX: 0, inY: 9, clockwise: true, outX: 0, outY: 0 },
    { inX: 0, inY: 0, clockwise: false, outX: 0, outY: 9 },
    { inX: 0, inY: 9, clockwise: false, outX: 9, outY: 9 },
    { inX: 9, inY: 9, clockwise: false, outX: 9, outY: 0 },
    { inX: 9, inY: 0, clockwise: false, outX: 0, outY: 0 }
  ];

  const boardSize = new BoardSize(10);

  rotateData.map(data => {
    const expected = new Coords({ x: data.outX, y: data.outY });

    const coords = new Coords({ x: data.inX, y: data.inY });
    const result = Map.translateRotation(boardSize, coords, data.clockwise);
    return expect(result).toEqual(expected);
  });
});

test("Correct board size with shrinking", () => {
  const board = new Board([
    [0, 1, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0]
  ]);

  const boardSize = new BoardSize(5); // 5 is minimal actually

  const expected = new Board([
    [0, 1, 0, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 1, 0, 0, 0]
  ]);

  const result = Map.correctBoardSizeChange(board, boardSize);
  expect(result).toEqual(expected);
});

test("Correct board size with growing", () => {
  const board = new Board([
    [0, 1, 0, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 1, 0, 0, 0]
  ]);

  const boardSize = new BoardSize(6);

  const tile = Map.cloneTile(1);

  const expected = new Board([
    [0, 1, 0, 0, 0, tile],
    [0, 1, 0, 0, 0, tile],
    [0, 1, 0, 0, 0, tile],
    [0, 1, 0, 0, 0, tile],
    [0, 1, 0, 0, 0, tile],
    [tile, tile, tile, tile, tile, tile]
  ]);

  const result = Map.correctBoardSizeChange(board, boardSize);
  expect(result).toEqual(expected);
});

test("Correct non-existant empty board to reasonably full one", () => {
  const board = new Board([]);

  const boardSize = new BoardSize(5);

  const tile = Map.cloneTile(1);

  const expected = new Board([
    [tile, tile, tile, tile, tile],
    [tile, tile, tile, tile, tile],
    [tile, tile, tile, tile, tile],
    [tile, tile, tile, tile, tile],
    [tile, tile, tile, tile, tile]
  ]);

  const result = Map.correctBoardSizeChange(board, boardSize);
  expect(result).toEqual(expected);
});

test("Make board from array", () => {
  const boardArray = [[{ id: 1 }, { id: 2 }], [{ id: 2 }, { id: 1 }]];

  const boardSize = new BoardSize(5);

  const tile1 = Map.cloneTile(1).modify({ x: 0, y: 0 });
  const tile2 = Map.cloneTile(2).modify({ x: 1, y: 0 });

  const tile3 = Map.cloneTile(2).modify({ x: 0, y: 1 });
  const tile4 = Map.cloneTile(1).modify({ x: 1, y: 1 });

  const expected = new Board([[tile1, tile3], [tile2, tile4]]);

  const result = Map.makeBoardFromArray(boardArray);
  expect(result).toEqual(expected);
});

test("Don't get new player direction on rotate", () => {
  const direction = new Coords({
    x: 1,
    y: 0
  });
  const actual = Map.getNewPlayerDirection(direction, true);

  expect(actual).toEqual(direction);
});

test("Do get new player direction on clockwise rotate", () => {
  const direction = new Coords({
    x: 0,
    y: 0
  });
  const expected = new Coords({
    x: 1,
    y: 0
  });
  const actual = Map.getNewPlayerDirection(direction, true);

  expect(actual).toEqual(expected);
});

test("Do get new player direction on anti-clockwise rotate", () => {
  const direction = new Coords({
    x: 0,
    y: 0
  });
  const expected = new Coords({
    x: -1,
    y: 0
  });
  const actual = Map.getNewPlayerDirection(direction, false);

  expect(actual).toEqual(expected);
});

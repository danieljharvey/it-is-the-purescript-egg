import { Board } from "../../objects/Board";
import { BoardSize } from "../../objects/BoardSize";
import { Coords } from "../../objects/Coords";
import { Player } from "../../objects/Player";
import { Tile } from "../../objects/Tile";

import { Action } from "../Action";
import * as Map from "../Map";

import { TileSet } from "../TileSet";

import { is } from "immutable"; // comparison func

// create board with one Tile which is collectable
const makeSimpleBoard = () => {
  const tile = new Tile({
    x: 0,
    y: 0,
    collectable: 100
  });

  const boardArray = [[tile]];

  return new Board(boardArray);
};

test("Do nothing if player not centered on board in X axis", () => {
  const board = makeSimpleBoard();

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0,
      offsetX: 1
    })
  });

  const action = new Action();

  const output = action.checkPlayerTileAction(player, board, 0, "");

  expect(is(output.board, board)).toEqual(true);
});

test("Do nothing if player not centered on board in Y axis", () => {
  const board = makeSimpleBoard();

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0,
      offsetY: -10
    })
  });

  const action = new Action();

  const output = action.checkPlayerTileAction(player, board, 0, "");

  expect(is(output.board, board)).toEqual(true);
});

test("Do nothing if player has not moved", () => {
  const board = makeSimpleBoard();

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0
    }),
    moved: false
  });

  const action = new Action();

  const output = action.checkPlayerTileAction(player, board, 0, "");

  expect(is(output.board, board)).toEqual(true);
});

test("Change board if player has moved", () => {
  const board = makeSimpleBoard();

  const player = new Player({
    coords: new Coords({
      x: 0,
      y: 0
    }),
    moved: true
  });

  const action = new Action();

  const output = action.checkPlayerTileAction(player, board, 0, "");

  expect(is(output.board, board)).toEqual(false);
  expect(output.score).toEqual(100); // tile was collected
});

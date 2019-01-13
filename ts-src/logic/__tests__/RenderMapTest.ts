import { Board } from "../../objects/Board";
import { BoardSize } from "../../objects/BoardSize";
import { Coords } from "../../objects/Coords";
import { Player } from "../../objects/Player";

import * as Map from "../Map";
import { RenderMap } from "../RenderMap";
import { TileSet } from "../TileSet";

test("Create render map from board changes", () => {
  const tile1 = Map.cloneTile(1);
  const tile2 = Map.cloneTile(2);

  const boardArray = [
    [tile1, tile1, tile1],
    [tile1, tile1, tile1],
    [tile1, tile1, tile1]
  ];

  const board = new Board(boardArray);

  const newBoard = board.modify(2, 2, tile2);

  const expected = [
    [false, false, false],
    [false, false, false],
    [false, false, true]
  ];

  const result = RenderMap.createRenderMapFromBoards(board, newBoard);
  expect(result).toEqual(expected);
});

test("Create path finding map", () => {
  const background = Map.cloneTile(1);
  const solid = Map.cloneTile(2);

  const boardArray = [
    [background, solid, background],
    [solid, background, solid],
    [background, solid, background]
  ];

  const board = new Board(boardArray);

  const expected = [
    [false, true, false],
    [true, false, true],
    [false, true, false]
  ];

  const result = RenderMap.createPathFindingMapFromBoard(board);
  expect(result).toEqual(expected);
});

test("Combine render maps", () => {
  const renderMap1 = [
    [false, false, false],
    [false, false, false],
    [false, false, true]
  ];

  const renderMap2 = [
    [true, false, false],
    [false, true, false],
    [false, false, false]
  ];

  const expected = [
    [true, false, false],
    [false, true, false],
    [false, false, true]
  ];

  const result = RenderMap.combineRenderMaps(renderMap1, renderMap2);
  expect(result).toEqual(expected);
});

test("Create small render map", () => {
  const expected = [
    [true, true, true, true, true],
    [true, true, true, true, true],
    [true, true, true, true, true],
    [true, true, true, true, true],
    [true, true, true, true, true]
  ];

  const result = RenderMap.createRenderMap(5, true);
  expect(result).toEqual(expected);
});

test("Mark render map with player in center", () => {
  const originalMap = [
    [false, false, false, false, false],
    [false, false, false, false, false],
    [false, false, false, false, false],
    [false, false, false, false, false],
    [false, false, false, false, false]
  ];

  const player = new Player({
    coords: new Coords({ x: 2, y: 2 })
  });

  const expected = [
    [false, false, false, false, false],
    [false, true, true, true, false],
    [false, true, true, true, false],
    [false, true, true, true, false],
    [false, false, false, false, false]
  ];

  const result = RenderMap.addPlayerToRenderMap(player, originalMap);
  expect(result).toEqual(expected);
});

test("Mark render map with player at side of grid", () => {
  const originalMap = [
    [false, false, false, false, false],
    [false, false, false, false, false],
    [false, false, false, false, false],
    [false, false, false, false, false],
    [false, false, false, false, false]
  ];

  const player = new Player({
    coords: new Coords({ x: 4, y: 4 })
  });

  const expected = [
    [true, false, false, true, true],
    [false, false, false, false, false],
    [false, false, false, false, false],
    [true, false, false, true, true],
    [true, false, false, true, true]
  ];

  const result = RenderMap.addPlayerToRenderMap(player, originalMap);
  expect(result).toEqual(expected);
});

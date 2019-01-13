import { Board } from "../Board";

test("Set up basic board", () => {
  const array = [[1, 2, 3], [4, 5, 6], [7, 8, 9]];

  const board = new Board(array);

  const found = board.getTile(2, 1);
  expect(found).toEqual(8);
});

test("Change an item on the board", () => {
  const array = [[1, 2, 3], [4, 5, 7]];

  const board = new Board(array);

  const updatedBoard = board.modify(1, 2, 6);

  const foundTile = updatedBoard.getTile(1, 2);

  expect(foundTile).toEqual(6);
});

test("Get the length of the list", () => {
  const array = [[1, 2, 3], [4, 5, 6]];

  const board = new Board(array);

  expect(board.getLength()).toEqual(2);
});

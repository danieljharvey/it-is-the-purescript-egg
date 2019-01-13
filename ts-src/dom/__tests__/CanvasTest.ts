import { BoardSize } from "../../objects/BoardSize";
import { Canvas } from "../Canvas";

test("Get top of canvas to vertically center", () => {
  const windowHeight = 400;

  const boardHeight = 200;

  const expected = 100;

  const boardSize = new BoardSize(10);
  const canvas = new Canvas(boardSize);

  const actual = canvas.getCanvasTop(windowHeight, boardHeight);

  expect(actual).toEqual(expected);
});

test("Sit at top by default", () => {
  const windowHeight = 400;

  const boardHeight = 400;

  const expected = 0;

  const boardSize = new BoardSize(10);
  const canvas = new Canvas(boardSize);

  const actual = canvas.getCanvasTop(windowHeight, boardHeight);

  expect(actual).toEqual(expected);
});

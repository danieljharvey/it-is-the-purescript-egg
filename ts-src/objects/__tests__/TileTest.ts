import { Tile } from "../Tile";

test("Test create new object", () => {
  const tile = new Tile({ x: 3, y: 10, id: 500 });

  expect(tile.x).toEqual(3);
  expect(tile.y).toEqual(10);
  expect(tile.id).toEqual(500);
});

test("Test modify object", () => {
  const tile = new Tile({ x: 3, y: 10, id: 500 });

  const newTile = tile.modify({ y: 100, id: 90 });

  expect(newTile.x).toEqual(3);
  expect(newTile.y).toEqual(100);
  expect(newTile.id).toEqual(90);
});

test("Test using createPlayer", () => {
  const tile = new Tile({ x: 3, y: 10, createPlayer: "dog" });

  expect(tile.createPlayer).toEqual("dog");
});

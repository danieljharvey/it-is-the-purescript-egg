import { Coords } from "../Coords";

test("Modify function", () => {
  const coords = new Coords({ x: 1, y: 2, offsetX: 3, offsetY: 4 });

  const newCoords = coords.modify({ y: 10 });

  const expected = new Coords({ x: 1, y: 10, offsetX: 3, offsetY: 4 });

  expect(newCoords).toEqual(expected);
});

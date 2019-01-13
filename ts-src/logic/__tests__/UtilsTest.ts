import { Utils } from "../Utils";

test("Flattens multi dimensional array", () => {
  const arr = [[1, 3], [5, 6]];

  const expected = [1, 3, 5, 6];

  const actual = Utils.flattenArray(arr);

  expect(actual).toEqual(expected);
});

test("Removes duplicates", () => {
  const arr = [1, 3, 3, 2];

  const expected = [1, 3, 2];

  const actual = Utils.removeDuplicates(arr);

  expect(actual).toEqual(expected);
});

test("Get player by value", () => {
  const playerTypes = {
    madeUp: {
      frames: 18,
      img: "egg-sprite.png",
      multiplier: 1,
      title: "It is of course the egg",
      type: "madeUp",
      value: 15
    },
    wrong: {
      frames: 18,
      img: "egg-sprite.png",
      multiplier: 1,
      title: "It is of course the egg",
      type: "madeUp",
      value: 10
    }
  };

  const expected = {
    frames: 18,
    img: "egg-sprite.png",
    multiplier: 1,
    title: "It is of course the egg",
    type: "madeUp",
    value: 15
  };

  const actual = Utils.getPlayerByValue(playerTypes, 15);

  expect(actual).toEqual(expected);
});

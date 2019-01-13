import { Coords } from "../Coords";
import { Player } from "../Player";

import { fromJS } from "immutable";

test("Create a player and check defaults", () => {
  const player = new Player({});
  expect(player.direction).toEqual(new Coords());
  expect(player.oldDirection).toEqual(new Coords());
  expect(player.currentFrame).toEqual(0);
});

test("Modify no coords", () => {
  const player = new Player({
    direction: new Coords({
      x: 1,
      y: 0
    })
  });

  const expectedPlayer = new Player({
    direction: new Coords({
      x: -1,
      y: 0
    })
  });

  const newPlayer = player.modify({
    direction: new Coords({
      x: -1,
      y: 0
    })
  });

  expect(newPlayer).toEqual(expectedPlayer);
});

test("Player has expected default coords", () => {
  const player = new Player();

  expect(player.coords.x).toEqual(0);
  expect(player.coords.y).toEqual(0);
  expect(player.coords.offsetX).toEqual(0);
  expect(player.coords.offsetY).toEqual(0);
});

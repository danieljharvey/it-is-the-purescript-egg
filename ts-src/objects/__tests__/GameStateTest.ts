import { GameState } from "../GameState";

test("Create a GameState and check defaults", () => {
  const gameState = new GameState();
  expect(gameState.score).toEqual(0);
});

test("Modify something", () => {
  const gameState = new GameState();

  const newGameState = gameState.modify({
    score: 10
  });

  const newerGameState = newGameState.modify({
    score: 100
  });

  expect(gameState.score).toEqual(0);
  expect(newGameState.score).toEqual(10);
  expect(newerGameState.score).toEqual(100);
});

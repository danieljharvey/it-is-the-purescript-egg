module Egg.Logic.TakeTurn where

import Prelude

import Egg.Logic.Movement as Movement

import Egg.Types.GameState (GameState)
import Egg.Types.Player (Player)
import Egg.Types.Action (Action(..))

go :: Int -> GameState -> GameState
go i gs = doAction gs Playing i

doAction :: GameState -> Action -> Int -> GameState
doAction old Paused _  = old
doAction old Playing i | i >= 1 = doGameMove i old
doAction old Playing _ = old
doAction old RotateAntiClockwise _ = doRotate old false
doAction old RotateClockwise _ = doRotate old true

incrementTurnCount :: GameState -> GameState
incrementTurnCount gameState
  = gameState { turns = next }
  where
    next = gameState.turns + 1

doGameMove :: Int -> GameState -> GameState
doGameMove i = (doPlayerMove i) <<< incrementTurnCount <<< resetOutcome

doPlayerMove :: Int -> GameState -> GameState
doPlayerMove i old = old { players = newPlayers }
  where
    newPlayers = Movement.movePlayers i old.players

isRainbowEggTime :: GameState -> Array Player
isRainbowEggTime gameState = gameState.players

doRotate :: GameState -> Boolean -> GameState
doRotate gameState clockwise = gameState

resetOutcome :: GameState -> GameState
resetOutcome gs = gs { outcome = "" }

{-

  // this is where we have to do a shitload of things
  protected doGameMove(gameState: GameState, timePassed: number): GameState {

    const newGameState = Movement.doCalcs(startGameState, timePassed);

    const action = new Action();
    const newerGameState = action.checkAllPlayerTileActions(newGameState);

    const collisions = new Collisions();
    const sortedPlayers = collisions.checkAllCollisions(newerGameState.players);

    const splitPlayers = BoardCollisions.checkBoardCollisions(
      newerGameState.board,
      sortedPlayers
    );

    const colouredPlayers = this.checkNearlyFinished(
      newerGameState.modify({
        players: splitPlayers
      })
    );

    return newerGameState.modify({
      players: colouredPlayers
    });
  }

  protected checkNearlyFinished = (
    gameState: GameState
  ): Player[] => {
    if (Utils.checkLevelIsCompleted(gameState)) {
      return gameState.players.map(player => {
        if (player.value > 0) {
          const maybeNewPlayer = Utils.getPlayerType("rainbow-egg");
          return maybeNewPlayer.map(newPlayer => {
            return player.modify({
              ...newPlayer
            });
          }).valueOr(player)
        }
        return player;
      });
    }
    return gameState.players;
  };

  // this rotates board and players
  // it DOES NOT do animation - not our problem
  protected doRotate(gameState: GameState, clockwise: boolean): GameState {
    const rotations = gameState.rotations + 1;

    const boardSize = new BoardSize(gameState.board.getLength());

    const newBoard = Map.rotateBoard(gameState.board, clockwise);

    const rotatedPlayers = gameState.players.map(player => {
      return Map.rotatePlayer(boardSize, player, clockwise);
    });

    const rotateAngle: number = Map.changeRenderAngle(
      gameState.rotateAngle,
      clockwise
    );

    return gameState.modify({
      board: newBoard,
      players: rotatedPlayers,
      rotateAngle,
      rotations
    });
  }
-}

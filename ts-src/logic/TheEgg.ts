// this is the egg
// it accepts a GameState and an Action
// and returns a new GameState
// totally fucking stateless and burnable in itself

import { is } from "immutable";

import { Action } from "./Action";
import * as BoardCollisions from "./BoardCollisions";
import { Collisions } from "./Collisions";
import * as Map from "./Map";
import * as Movement from "./Movement";
import { Utils } from "./Utils";

import { playerTypes } from "../data/PlayerTypes";

import { Board } from "../objects/Board";
import { BoardSize } from "../objects/BoardSize";
import { GameState } from "../objects/GameState";
import { Player } from "../objects/Player";

export class TheEgg {

  public doAction(
    gameState: GameState,
    action: string,
    timePassed: number
  ): GameState {
    if (action === "rotateLeft") {
      return this.doRotate(gameState, false);
    } else if (action === "rotateRight") {
      return this.doRotate(gameState, true);
    } else if (action === "") {
      return this.doGameMove(gameState, timePassed);
    }
    return gameState;
  }

  // this is where we have to do a shitload of things
  protected doGameMove(gameState: GameState, timePassed: number): GameState {
    // first get rid of old outcome
    const startGameState = gameState.modify({
      outcome: ""
    });

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
}

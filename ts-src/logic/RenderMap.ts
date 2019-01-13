import { Board } from "../objects/Board";
import { BoardSize } from "../objects/BoardSize";
import { Coords } from "../objects/Coords";
import { Player } from "../objects/Player";

import * as Map from "./Map";
import { Utils } from "./Utils";

// this is not a render map object, but a class for making them

export class RenderMap {
  // render map

  public static copyRenderMap(renderMap: boolean[][]): boolean[][] {
    return renderMap.slice(0);
  }

  // add player to renderMap, returning new renderMap
  public static addPlayerToRenderMap(
    player: Player,
    renderMap: boolean[][]
  ): boolean[][] {
    const coords = player.coords;

    const startX = coords.x - 1;
    const endX = coords.x + 1;

    const startY = coords.y - 1;
    const endY = coords.y + 1;

    const newRenderMap = this.copyRenderMap(renderMap);

    const boardSize = new BoardSize(renderMap.length);

    for (let x = startX; x <= endX; x++) {
      for (let y = startY; y <= endY; y++) {
        const newCoords = new Coords({ x, y });
        const fixedCoords = Utils.correctForOverflow(newCoords, boardSize);
        newRenderMap[fixedCoords.x][fixedCoords.y] = true;
      }
    }
    return newRenderMap;
  }

  public static createMap = (board: Board, func): boolean[][] => {
    const boardArray = RenderMap.createRenderMap(board.getLength(), false);
    return boardArray.map((column, x) => {
      return column.map((tile, y) => {
        return func(board, x, y);
      });
    });
  };

  // takes oldBoard and newBoard and creates a map of changes between them
  public static createRenderMapFromBoards(
    oldBoard: Board,
    newBoard: Board
  ): boolean[][] {
    const renderFunc = RenderMap.renderMapMaker(newBoard);
    return RenderMap.createMap(oldBoard, renderFunc);
  }

  public static renderMapMaker(newBoard: Board) {
    return (board: Board, x: number, y: number): boolean => {
      const oldTile = board.getTile(x, y);
      const newTile = newBoard.getTile(x, y);
      return !oldTile.equals(newTile);
    };
  }

  // returns map of boolean values for background or not for pathfinding
  public static createPathFindingMapFromBoard(board: Board): boolean[][] {
    return RenderMap.createMap(
      board,
      (newBoard: Board, x: number, y: number) => {
        return !Map.checkTileIsEmpty(newBoard, x, y);
      }
    );
  }

  // combines any two renderMaps (using OR)
  // assumes they are same size
  public static combineRenderMaps(
    renderMap: boolean[][],
    newRenderMap: boolean[][]
  ) {
    return renderMap.map((column, x) => {
      return column.map((entry, y) => {
        return entry || newRenderMap[x][y];
      });
    });
  }

  // create an empty render map
  public static createRenderMap(size: number, value: boolean) {
    const boardArray = [];
    for (let x = 0; x < size; x++) {
      boardArray[x] = [];
      for (let y = 0; y < size; y++) {
        boardArray[x][y] = value;
      }
    }
    return boardArray;
  }

  // end of render map
}

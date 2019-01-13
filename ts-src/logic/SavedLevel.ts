import { BoardSize } from "../objects/BoardSize";

export class SavedLevel {
  public board: any;
  public boardSize: BoardSize;
  public levelID: number;

  constructor(boardSize: BoardSize, board: any, levelID: number) {
    this.boardSize = boardSize;
    this.board = board;
    this.levelID = levelID;
  }

  public toString() {
    const data = this.getData();
    return JSON.stringify(data);
  }

  public getData() {
    return {
      board: this.board,
      boardSize: this.boardSize.getData(),
      levelID: this.levelID
    };
  }
}

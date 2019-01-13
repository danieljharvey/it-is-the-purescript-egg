import { Board } from "./Board";
import { Player } from "./Player";

interface IGameState {
  players?: Player[];
  board?: Board;
  score?: number;
  rotations?: number;
  rotateAngle?: number;
  outcome?: string;
}

export class GameState {
  public players: Player[] = [];
  public board: Board = null;
  public score: number = 0;
  public rotations: number = 0;
  public rotateAngle: number = 0;
  public outcome: string = "";

  constructor(params: IGameState = {}) {
    (Object as any).entries(params).map(pair => {
      const [key, value] = pair;
      this[key] = value;
    });
  }

  public modify(values: IGameState = {}) {
    return new GameState((Object as any).assign({}, this, values));
  }
}

import { Record } from "immutable";

interface ITileParams {
  id?: number;
  title?: string;
  img?: string;
  background?: boolean;
  frontLayer?: boolean;
  collectable?: number;
  breakable?: boolean;
  action?: string;
  dontAdd?: boolean;
  createPlayer?: string;
  x?: number;
  y?: number;
}

export class Tile extends Record({
  action: "",
  background: false,
  breakable: false,
  collectable: 0,
  createPlayer: "",
  dontAdd: false,
  frontLayer: false,
  id: 0,
  img: "",
  title: "Title",
  x: 0,
  y: 0
}) {
  public id: number;
  public title: string;
  public img: string;
  public background: boolean;
  public frontLayer: boolean;
  public collectable: number;
  public breakable: boolean;
  public action: string;
  public dontAdd: boolean;
  public createPlayer: string;
  public x: number;
  public y: number;

  constructor(params?: ITileParams) {
    const superParams = params ? params : undefined;
    super(superParams);
  }

  public modify(values: ITileParams) {
    return this.merge(values) as this;
  }
}

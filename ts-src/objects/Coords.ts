import { Record } from "immutable";
// import { Utils } from "./Utils";

const OFFSET_DIVIDE: number = 100;

interface ICoordsParams {
  x?: number;
  y?: number;
  offsetX?: number;
  offsetY?: number;
}

export class Coords extends Record({ x: 0, y: 0, offsetX: 0, offsetY: 0 }) {
  public x: number;
  public y: number;
  public offsetX: number;
  public offsetY: number;

  constructor(params?: ICoordsParams) {
    const superParams = params ? params : undefined;
    super(superParams);
  }

  public modify(values: ICoordsParams) {
    return this.merge(values) as this;
  }

  public getActualPosition() {
    const fullX: number = this.x * OFFSET_DIVIDE + this.offsetX;
    const fullY: number = this.y * OFFSET_DIVIDE + this.offsetY;
    return {
      fullX,
      fullY
    };
  }
}

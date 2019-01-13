import { Record } from "immutable";
import { Coords } from "./Coords";

import { Utils } from "../logic/Utils";

const SPRITE_SIZE: number = 64;

interface IPlayerParams {
  coords?: Coords;
  direction?: Coords;
  oldDirection?: Coords;
  currentFrame?: number;
  id?: number;
  frames?: number;
  multiplier?: number;
  falling?: boolean;
  type?: string;
  moveSpeed?: number;
  fallSpeed?: number;
  value?: number;
  img?: string;
  stop?: boolean;
  lastAction?: string;
  title?: string;
  moved?: boolean;
  flying?: boolean;
  movePattern?: string;
}

export class Player extends Record({
  coords: new Coords(),
  currentFrame: 0,
  direction: new Coords(),
  fallSpeed: 1,
  falling: false,
  frames: 1,
  id: 0,
  img: "",
  lastAction: "",
  moveSpeed: 1,
  moved: false,
  multiplier: 1,
  oldDirection: new Coords(),
  stop: false,
  title: "",
  type: "egg",
  value: 1,
  flying: false,
  movePattern: ""
}) {
  public coords: Coords;
  public direction: Coords;
  public oldDirection: Coords;
  public currentFrame: number;
  public id: number;
  public frames: number;
  public multiplier: number;
  public falling: boolean;
  public type: string;
  public moveSpeed: number;
  public fallSpeed: number;
  public value: number;
  public img: string;
  public stop: boolean;
  public lastAction: string;
  public title: string;
  public moved: boolean;
  public flying: boolean;
  public movePattern: string;

  constructor(params?: IPlayerParams) {
    const superParams = params ? params : undefined;
    super(superParams);
  }

  public modify(values: IPlayerParams) {
    return this.merge(values) as this;
  }

  public first() {
    return this.first();
  }
}

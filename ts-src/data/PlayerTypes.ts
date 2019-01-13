import { Player } from "../objects/Player"

export interface IPlayerType {
  frames: number
  img: string
  multiplier?: number
  title: string
  type: string
  value: number
  fallSpeed?: number
  moveSpeed?: number
  flying?: boolean
  movePattern?: string
}

export const playerTypes: IPlayerType[] = [
  {
    frames: 18,
    img: "egg-sprite-blue.png",
    multiplier: 5,
    title: "It is of course the blue egg",
    type: "blue-egg",
    value: 3
  },
  {
    frames: 18,
    img: "egg-sprite.png",
    multiplier: 1,
    title: "It is of course the egg",
    type: "egg",
    value: 1
  },
  {
    frames: 18,
    img: "egg-sprite-red.png",
    multiplier: 2,
    title: "It is of course the red egg",
    type: "red-egg",
    value: 2
  },
  {
    fallSpeed: 20,
    frames: 1,
    img: "silver-egg.png",
    moveSpeed: 0,
    multiplier: 10,
    title: "It is of course the silver egg",
    type: "silver-egg",
    value: 0
  },
  {
    frames: 18,
    img: "egg-sprite-yellow.png",
    multiplier: 10,
    title: "It is of course the yellow egg",
    type: "yellow-egg",
    value: 4
  },
  {
    frames: 18,
    img: "egg-rainbow.png",
    multiplier: 1,
    title: "It goes without saying that this is the rainbow egg",
    type: "rainbow-egg",
    value: 1
  },
  {
    frames: 18,
    img: "blade-sprite.png",
    title: "It is the mean spirited blade",
    type: "blade",
    value: 0,
    flying: true
  },
  {
    frames: 18,
    img: "find-blade-sprite.png",
    title: "It is the mean spirited blade",
    type: "find-blade",
    value: 0,
    movePattern: "seek-egg",
    flying: true
  }
];

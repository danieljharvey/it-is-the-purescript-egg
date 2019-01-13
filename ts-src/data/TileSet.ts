import { Tile } from "../objects/Tile"

export const tiles = [
  new Tile({
    background: true,
    id: 1,
    img: "sky.png",
    title: "Sky"
  }),
  new Tile({
    background: false,
    id: 2,
    img: "fabric.png",
    title: "Fabric"
  }),
  new Tile ({
    background: true,
    collectable: 1,
    frontLayer: true,
    id: 3,
    img: "cacti.png",
    title: "Cacti"
  }),
  new Tile({
    background: true,
    collectable: 10,
    frontLayer: true,
    id: 4,
    img: "plant.png",
    title: "Plant"
  }),
  new Tile({
    background: false,
    breakable: true,
    id: 5,
    img: "crate.png",
    title: "Crate"
  }),
  new Tile({
    background: false,
    id: 8,
    img: "work-surface-2.png",
    title: "Work surface 2"
  }),
  new Tile({
    background: false,
    id: 9,
    img: "work-surface-3.png",
    title: "Work surface 3"
  }),
  new Tile({
    background: false,
    id: 10,
    img: "work-surface-4.png",
    title: "Work surface 4"
  }),
  new Tile({
    background: false,
    id: 11,
    img: "tile.png",
    title: "Tiles"
  }),
  new Tile({
    action: "completeLevel",
    background: true,
    createPlayer: "egg",
    frontLayer: true,
    id: 12,
    img: "egg-cup.png",
    title: "Egg Cup"
  }),
  new Tile({
    background: true,
    collectable: 100,
    dontAdd: true,
    frontLayer: true,
    id: 13,
    img: "toast.png",
    title: "Toast"
  }),
  new Tile({
    action: "teleport",
    background: true,
    frontLayer: true,
    id: 14,
    img: "door.png",
    title: "Door"
  }),
  new Tile({
    background: true,
    frontLayer: true,
    id: 15,
    img: "pink-door-open.png",
    title: "Pink door open"
  }),
  new Tile({
    background: false,
    id: 16,
    img: "pink-door.png",
    title: "Pink door closed"
  }),
  new Tile({
    action: "pink-switch",
    background: true,
    frontLayer: true,
    id: 17,
    img: "pink-switch.png",
    title: "Pink door switch"
  }),
  new Tile({
    background: true,
    frontLayer: true,
    id: 18,
    img: "green-door-open.png",
    title: "Green door open"
  }),
  new Tile({
    background: false,
    id: 19,
    img: "green-door.png",
    title: "Green door closed"
  }),
  new Tile({
    action: "green-switch",
    background: true,
    frontLayer: true,
    id: 20,
    img: "green-switch.png",
    title: "Green door switch"
  }),
  new Tile({
    background: true,
    createPlayer: "silver-egg",
    frontLayer: true,
    id: 21,
    img: "silver-egg-cup.png",
    title: "Silver Egg Cup"
  }),
  new Tile({
    background: true,
    createPlayer: "blade",
    frontLayer: true,
    id: 22,
    img: "blade-egg-cup.png",
    title: "Blade egg cup"
  }),
  new Tile({
    background: true,
    createPlayer: "find-blade",
    frontLayer: true,
    id: 23,
    img: "find-blade-egg-cup.png",
    title: "Find-blade egg cup"
  }),
  new Tile({
    background: true,
    id: 24,
    action: "split-eggs",
    frontLayer: true,
    img: "egg-splitter.png",
    title: "It is the egg splitter"
  })
];

export const getTile = id => {
  return tiles.find(tile => {
    return tile.id === id;
  });
};

import { Board } from "../objects/Board";
import { BoardSize } from "../objects/BoardSize";
import { Coords } from "../objects/Coords";
import { Player } from "../objects/Player";
import { Tile } from "../objects/Tile";

import { playerTypes } from "../data/PlayerTypes"
import * as Map from "../logic/Map";
import { teleport } from "../logic/Movement";
import { Utils } from "../logic/Utils";

import { getTile, tiles as originalTiles } from "../data/TileSet"
import { Canvas } from "./Canvas";

import { maybe, Maybe } from "tsmonad";

const SPRITE_SIZE: number = 64;
const OFFSET_DIVIDE: number = 100;

interface IDomImage {
  title: string
  image: HTMLImageElement
  ready: boolean
}

type RenderMap = boolean[][]

export class Renderer {
  public tileSize: number;

  protected boardSize: BoardSize;
  protected canvas: Canvas;

  protected animationHandle: number; // used only in rotations

  protected renderMap: RenderMap; // map of screen with whether it needs rendering

  protected checkResize: boolean = true;

  protected tileImages: IDomImage[] = []; // image elements of tiles
  protected playerImages: IDomImage[] = []; // image element of players

  protected rotating: boolean;

  protected loadCallback: () => void; // call this when all the tiles are loaded

  constructor(
    boardSize: BoardSize,
    canvas: Canvas,
    loadCallback: () => void
  ) {
    this.boardSize = boardSize;
    this.canvas = canvas;
    this.loadCallback = loadCallback;
    this.loadTilePalette(originalTiles);
    this.loadPlayerPalette();
  }

  public render(
    board: Board,
    renderMap: boolean[][],
    players: Player[],
    renderAngle: number
  ) {
    this.tileSize = this.canvas.calcTileSize(this.boardSize);
    this.renderBoard(board, renderMap, renderAngle);
    this.renderPlayers(players);
  }

  public resize(boardSize: BoardSize) {
    this.boardSize = boardSize;
    this.tileSize = this.canvas.sizeCanvas(boardSize);
  }

  public drawRotatingBoard(
    clockwise: boolean,
    moveSpeed: number,
    completed: () => void
  ) {
    if (this.rotating === true) {
      // already
      return false;
    }

    const canvas = this.canvas.getCanvas();
    const savedData = this.getImageData(canvas);
    this.rotating = true;

    if (clockwise) {
      this.drawRotated(savedData, 1, 0, 90, moveSpeed, completed);
    } else {
      this.drawRotated(savedData, -1, 0, -90, moveSpeed, completed);
    }
  }

  protected getImageData(canvas: HTMLCanvasElement): HTMLImageElement {
    const cw = canvas.width;
    const ch = canvas.height;

    const savedData = new Image();
    savedData.src = canvas.toDataURL("image/png");

    return savedData;
  }

  protected loadTilePalette(tiles: Tile[]) {
    const tilePromises = tiles.map(this.loadTileImage)
    Promise.all(tilePromises).then(data => {
      this.tileImages = data

      if (this.loadIsCompleted()) {
        this.loadCallback()
      }
        
    }).catch(() => {
      this.tileImages = []
    })
  }

  protected loadIsCompleted = () =>  (this.tileImages.length > 0 && this.playerImages.length > 0) 

  protected loadTileImage(tile: Tile): Promise<IDomImage> {
    return new Promise((resolve, reject) => {
      const tileImage = document.createElement("img");
      tileImage.setAttribute("src", Utils.getTileImagePath(tile.img))
      tileImage.setAttribute("width", SPRITE_SIZE.toString());
      tileImage.setAttribute("height", SPRITE_SIZE.toString());
      tileImage.addEventListener(
        "load",
        () => {
          return resolve({
            title: tile.img,
            image: tileImage,
            ready: true
          })
        },
        false
      );
      tileImage.addEventListener(
        "onerror",
        () => {
          return reject("Could not load tile image")
        },false
      )
    })
  }

  protected loadPlayerPalette() {
    const playerPromises = playerTypes.map(this.loadPlayerImage)
    Promise.all(playerPromises).then(data => {
      
      this.playerImages = data

      if (this.loadIsCompleted()) {
        this.loadCallback()
      }

    }).catch(() => {
      this.playerImages = []
    })
  }

  protected loadPlayerImage(playerType): Promise<IDomImage> {
    return new Promise((resolve, reject) => {
      const playerImage = document.createElement("img");
      playerImage.setAttribute("src", Utils.getTileImagePath(playerType.img));
      playerImage.addEventListener(
        "load",
        () => {
          return resolve({
            title: playerType.img,
            image: playerImage,
            ready: true
          })
        },
        false
      );
      playerImage.addEventListener(
        "onerror",
        () => {
          return reject("Could not load player image")
        },false
      )
    })
  }

  protected renderBoard(
    board: Board,
    renderMap: boolean[][],
    renderAngle: number
  ): void {
    const ctx = this.canvas.getDrawingContext();
    ctx.globalCompositeOperation = "source-over";
    ctx.globalAlpha = 1;
    const tiles = board.getAllTiles();
    const drawable = tiles.filter(tile => renderMap[tile.x][tile.y]);
    drawable.filter(tile => tile.frontLayer || tile.id === 1).map(tile => {
      this.clearTile(ctx, tile.x, tile.y);
      return tile;
    });
    drawable.filter(tile => tile.id > 1).map(tile => {
      this.renderTile(tile.x, tile.y, tile, renderAngle);
    });
  }

  protected clearTile(ctx, x: number, y: number) {
    const tileSize = this.tileSize;
    const left = Math.floor(x * tileSize);
    const top = Math.floor(y * tileSize);
    ctx.clearRect(left, top, tileSize, tileSize);
  }

  protected drawSkyTile(tile: Tile, x: number, y: number, renderAngle: number) {
    const skyTile = getTile(1)
    this.renderTile(x, y, skyTile, renderAngle);
  }

  protected renderPlayers(players: Player[]) {
    players.map(player => {
      return this.renderPlayer(player);
    });
  }

  protected getTileImage(tile: Tile) : Maybe<HTMLImageElement> {
    return maybe(this.tileImages.find(tileImage => 
      (tileImage.title === tile.img)
    )).map(tileImage => tileImage.image)
  }

  protected renderTile = function(
    x: number,
    y: number,
    tile: Tile,
    renderAngle: number
  ): boolean {
    const ctx = this.canvas.getDrawingContext();
    const tileSize = this.tileSize;

    const maybeImg = this.getTileImage(tile);

    return maybeImg.map(img => {
      let left = Math.floor(x * tileSize);
      let top = Math.floor(y * tileSize);

      if (renderAngle === 0) {
        ctx.drawImage(img, left, top, tileSize, tileSize);
      } else {
        const angleInRad = renderAngle * (Math.PI / 180);

        const offset = Math.floor(tileSize / 2);

        left = Math.floor(left + offset);
        top = Math.floor(top + offset);

        ctx.translate(left, top);
        ctx.rotate(angleInRad);

        ctx.drawImage(img, -offset, -offset, tileSize, tileSize);

        ctx.rotate(-angleInRad);
        ctx.translate(-left, -top);
      }

      return true;
    }).valueOr(false)
  };

  protected getPlayerImage(img: string): Maybe<HTMLImageElement> {
    return maybe(this.playerImages.find(playerImage => 
      (playerImage.title === img)
    )).map(playerImage => playerImage.image)
  }

  protected renderPlayer(player: Player) {
    const ctx = this.canvas.getDrawingContext();
    const tileSize = this.tileSize;

    const offsetRatio = tileSize / OFFSET_DIVIDE;

    const coords = player.coords;

    const left = Math.floor(coords.x * tileSize + coords.offsetX * offsetRatio);
    const top = Math.floor(coords.y * tileSize + coords.offsetY * offsetRatio);

    const clipLeft = Math.floor(player.currentFrame * SPRITE_SIZE);
    const clipTop = 0;

    const maybeImage = this.getPlayerImage(player.img);
    maybeImage.map(image => {
      ctx.drawImage(
        image,
        clipLeft,
        0,
        SPRITE_SIZE,
        SPRITE_SIZE,
        left,
        top,
        tileSize,
        tileSize
      );
  
      if (left < 0) {
        // also draw on right
        const secondLeft = left + tileSize * this.boardSize.width;
        ctx.drawImage(
          image,
          clipLeft,
          0,
          SPRITE_SIZE,
          SPRITE_SIZE,
          secondLeft,
          top,
          tileSize,
          tileSize
        );
      }
  
      if (left + tileSize > tileSize * this.boardSize.width) {
        // also draw on left
        const secondLeft = left - tileSize * this.boardSize.width;
        ctx.drawImage(
          image,
          clipLeft,
          0,
          SPRITE_SIZE,
          SPRITE_SIZE,
          secondLeft,
          top,
          tileSize,
          tileSize
        );
      }
  
      if (top + tileSize > tileSize * this.boardSize.height) {
        // also draw on top
        const secondTop = top - tileSize * this.boardSize.height;
        ctx.drawImage(
          image,
          clipLeft,
          0,
          SPRITE_SIZE,
          SPRITE_SIZE,
          left,
          secondTop,
          tileSize,
          tileSize
        );
      }
    })
  }

  protected drawRotated(
    savedData: HTMLImageElement,
    direction: number,
    angle: number,
    targetAngle: number,
    moveSpeed: number,
    completed: () => any
  ) {
    const canvas = this.canvas.getCanvas();

    if (direction > 0) {
      if (angle >= targetAngle) {
        completed();
        this.rotating = false;
        return false;
      }
    } else {
      if (angle <= targetAngle) {
        completed();
        this.rotating = false;
        return false;
      }
    }

    const angleInRad = angle * (Math.PI / 180);

    const offset = canvas.width / 2;

    const ctx = this.canvas.getDrawingContext();

    const left = offset;
    const top = offset;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    ctx.translate(left, top);
    ctx.rotate(angleInRad);

    ctx.drawImage(savedData, -offset, -offset);

    ctx.rotate(-angleInRad);
    ctx.translate(-left, -top);

    angle += direction * (moveSpeed / 2);

    this.animationHandle = window.requestAnimationFrame(() => {
      this.drawRotated(
        savedData,
        direction,
        angle,
        targetAngle,
        moveSpeed,
        completed
      );
    });
  }
}

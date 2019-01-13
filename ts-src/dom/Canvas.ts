// responsible for the care and feeding of the html canvas and it's size on screen etc etc etc

import { BoardSize } from "../objects/BoardSize";

import { Utils } from "../logic/Utils";

export class Canvas {

  protected canvas: HTMLCanvasElement;
  protected ctx: CanvasRenderingContext2D;
  protected boardSize: BoardSize;

  constructor(boardSize: BoardSize) {
    this.boardSize = boardSize;
    const tileSize = this.sizeCanvas(boardSize);
    this.loadCanvas(boardSize, tileSize);
  }

  public getDrawingContext() {
    return this.ctx;
  }

  public getCanvas() {
    return this.canvas;
  }

  public wipeCanvas(fillStyle: string): void {
    this.ctx.fillStyle = fillStyle;
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
  }

  // takes BoardSize, returns size of each tile
  public sizeCanvas(boardSize: BoardSize) {
    const maxBoardSize = this.getMaxBoardSize(boardSize);

    const tileSize = this.calcTileSize(boardSize);

    this.loadCanvas(boardSize, tileSize);

    this.positionCanvas(maxBoardSize);

    this.boardSize = boardSize;

    return tileSize;
  }

  public positionCanvas(maxBoardSize: number) {
    const windowHeight = window.innerHeight;

    const canvasTop = this.getCanvasTop(windowHeight, maxBoardSize);

    const wrapper = document.getElementById("wrapper");

    if (wrapper) {
      wrapper.style.paddingTop = canvasTop.toString() + "px";
    }
  }

  public getCanvasTop(windowHeight, boardHeight) {
    if (boardHeight < windowHeight) {
      return (windowHeight - boardHeight) / 2;
    }
    return 0;
  }

  public calcTileSize(boardSize: BoardSize) {
    const maxBoardSize = this.getMaxBoardSize(this.boardSize);
    const tileSize = maxBoardSize / boardSize.width;
    return Math.floor(tileSize);
  }

  public darkBackground(): void {
    const background = document.getElementById("background") as HTMLDivElement;
    if (!background) {
      return;
    }
    if (!background.classList.contains("dark")) {
      background.classList.add("dark");
    }
  }

  public gradientBackground(): void {
    const background = document.getElementById("background") as HTMLDivElement;
    if (!background) {
      return;
    }
    if (background.classList.contains("dark")) {
      background.classList.remove("dark");
    }
  }

  protected getMaxBoardSize(boardSize: BoardSize): number {
    let width = window.innerWidth;
    let height = window.innerHeight;

    if (width > height) {
      const difference = height % boardSize.width;
      height = height - difference;
      return height;
    } else {
      const difference = width % boardSize.width;
      width = width - difference;
      return width;
    }
  }

  protected loadCanvas(boardSize, tileSize): void {
    this.canvas = document.getElementById("canvas") as HTMLCanvasElement;
    if (!this.canvas) {
      return;
    }
    this.canvas.width = boardSize.width * tileSize;
    this.canvas.height = boardSize.height * tileSize;
    this.ctx = this.canvas.getContext("2d");
    this.sizeBackground(boardSize, tileSize);
  }

  protected sizeBackground(boardSize, tileSize): void {
    const background = document.getElementById("background") as HTMLDivElement;
    if (!background) {
      return;
    }
    background.style.width = String(boardSize.width * tileSize) + "px";
    background.style.height = String(boardSize.height * tileSize) + "px";
    background.style.opacity = "1.0";
  }
}

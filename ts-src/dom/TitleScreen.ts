import { Jetpack } from "../Jetpack";
import { BoardSize } from "../objects/BoardSize";
import { Canvas } from "./Canvas";

import { Utils } from "../logic/Utils"

export class TitleScreen {
  protected jetpack: Jetpack;
  protected canvas: Canvas;
  protected imagePath: string; // image to show
  protected width: number; //
  protected height: number;

  constructor(
    jetpack: Jetpack,
    canvas: Canvas,
    imagePath: string,
    width: number,
    height: number
  ) {
    this.jetpack = jetpack;
    this.canvas = canvas;
    this.imagePath = Utils.getTileImagePath(imagePath);
    this.width = width;
    this.height = height;
  }

  public render(callback) {
    const boardSize = new BoardSize(10);
    this.canvas.sizeCanvas(boardSize);
    this.canvas.darkBackground();

    const titleImage: HTMLElement = document.createElement("img");
    titleImage.addEventListener(
      "load",
      () => {
        this.drawTheBigEgg(titleImage, 0.02, true, callback);
      },
      false
    );

    titleImage.setAttribute("src", this.imagePath);
    titleImage.setAttribute("width", this.width.toString());
    titleImage.setAttribute("height", this.height.toString());
  }

  protected drawTheBigEgg(
    titleImage,
    opacity: number,
    show: boolean,
    callback
  ) {
    const ctx = this.canvas.getDrawingContext();

    const canvas = this.canvas.getCanvas();
    this.canvas.darkBackground();

    ctx.globalAlpha = 1;
    ctx.globalCompositeOperation = "lighten";
    // this.canvas.wipeCanvas("rgb(0,0,0)");

    ctx.globalAlpha = opacity;

    ctx.drawImage(
      titleImage,
      0,
      0,
      titleImage.width,
      titleImage.height,
      0,
      0,
      canvas.width,
      canvas.height
    );
    if (show) {
      opacity += 0.01;
      if (opacity >= 1) {
        // wait, fade the egg
        const v = setTimeout(() => {
          // and start fading!
          this.drawTheBigEgg(titleImage, opacity, false, callback);
        }, 1000);
        return false;
      }
    } else {
      opacity = opacity - 0.03;
      if (opacity <= 0) {
        callback();
        titleImage = null;
        return false;
      }
    }
    this.jetpack.animationHandle = window.requestAnimationFrame(() => {
      this.drawTheBigEgg(titleImage, opacity, show, callback);
    });
  }
}

import { Board } from "./objects/Board";
import { BoardSize } from "./objects/BoardSize";
import { Coords } from "./objects/Coords";
import { Player } from "./objects/Player";

import { tiles } from "./data/TileSet";

import { Canvas } from "./dom/Canvas";
import { Levels } from "./dom/Levels";
import { Loader } from "./dom/Loader";
import { Renderer } from "./dom/Renderer";
import { TileChooser } from "./dom/TileChooser";
import { TitleScreen } from "./dom/TitleScreen";

import { Collisions } from "./logic/Collisions";
import * as Map from "./logic/Map";
import { RenderMap } from "./logic/RenderMap";
import { SavedLevel } from "./logic/SavedLevel";
import { Utils } from "./logic/Utils";

export class Editor {
  protected levelID: number = 1;
  protected levelList: number[] = [];

  protected renderer: Renderer; // Renderer object
  protected levels: Levels; // Levels object
  protected boardSize: BoardSize; // BoardSize object
  protected canvas: Canvas; // Canvas object
  protected tileChooser: TileChooser;
  protected board: Board;

  protected boardHistory: Board[] = [];

  protected defaultBoardSize: number = 20;

  // go function but for edit mode
  public edit() {
    this.levels.populateLevelsList(this.levelList);

    this.bindSizeHandler();
    this.bindClickHandler();
    this.bindMouseMoveHandler();

    this.board = this.getBlankBoard(this.boardSize);

    // reset undo
    this.clearBoardHistory(this.board);

    this.renderer = this.createRenderer(this.boardSize);
    window.setTimeout(() => {
      this.renderEverything(this.board);
    }, 1000);

    this.tileChooser = new TileChooser(this.renderer);
    this.tileChooser.render();
  }

  // load static stuff - map/renderer etc will be worked out later
  public bootstrap(callback) {
    this.boardSize = new BoardSize(this.defaultBoardSize);

    this.canvas = new Canvas(this.boardSize);

    const apiLocation = "http://" + window.location.hostname + "/levels/";

    const loader: Loader = new Loader(apiLocation);

    this.levels = new Levels(loader);

    this.getLevelList(levelList => {
      const levelID = this.chooseLevelID(levelList);
      this.levelID = levelID;
      callback(levelID);
    });
  }

  public saveLevel() {
    this.levels.saveLevel(
      this.board.toJS(),
      this.boardSize,
      this.levels.levelID,
      levelID => {
        const text = "Level " + levelID + " saved";
        this.showEditMessage(text);
      }
    );
  }

  public loadLevelFromList() {
    const select = document.getElementById("levelList") as HTMLSelectElement;
    const index = select.selectedIndex;
    const levelID = select.options[index].value;
    this.loadLevel(levelID, () => {
      // reset undo
      this.clearBoardHistory(this.board);
      // render everything (give sprites a second to load)
      window.setTimeout(() => {
        this.renderEverything(this.board);
      }, 1000);
    });
  }

  public growBoard() {
    const newBoard = Map.growBoard(this.board);
    this.boardSize = new BoardSize(newBoard.getLength());

    this.sizeCanvas(this.boardSize);
    this.updateBoard(newBoard);

    this.renderEverything(newBoard);
  }

  public shrinkBoard() {
    const newBoard = Map.shrinkBoard(this.board);
    this.boardSize = new BoardSize(newBoard.getLength());

    this.sizeCanvas(this.boardSize);
    this.updateBoard(newBoard);

    this.renderEverything(newBoard);
  }

  public undo() {
    if (this.boardHistory.length === 1) {
      return false;
    }
    this.boardHistory.pop(); // get rid of most recent
    this.board = this.boardHistory.slice(-1)[0]; // set to new last item
    this.boardSize = new BoardSize(this.board.getLength());
    this.renderEverything(this.board);
  }

  // replaces this.board with board
  // places old this.board in history
  protected updateBoard(board: Board) {
    this.boardHistory.push(board); // current state is always at top
    this.board = board;
  }

  protected getBlankBoard(boardSize: BoardSize): Board {
    return Map.generateBlankBoard(boardSize);
  }

  protected getLevelBoard(boardArray, boardSize: BoardSize): Board {
    return Map.makeBoardFromArray(boardArray);
  }

  protected clearBoardHistory(board: Board) {
    this.boardHistory = [board]; // reset to single state
  }

  protected getLevelList(callback) {
    this.levels.getLevelList(levelList => {
      this.levelList = levelList;
      callback(levelList);
    });
  }

  // select a random level that has not been completed yet
  // a return of false means none available (generate a random one)
  protected chooseLevelID(levelList) {
    const availableLevels = levelList.filter(level => {
      return level.completed === false;
    });
    const chosenKey = Utils.getRandomArrayKey(availableLevels);
    if (!chosenKey) {
      return false;
    }
    const levelID = availableLevels[chosenKey].levelID;
    return levelID;
  }

  // with no arguments this will cause a blank 12 x 12 board to be created and readied for drawing
  protected createRenderer(boardSize: BoardSize) {
    this.canvas = new Canvas(boardSize);
    this.boardSize = boardSize;

    return new Renderer(
      this.boardSize,
      this.canvas,
      () => {
        // 
      }
    );
  }

  protected renderEverything(board: Board) {
    const boardSize = new BoardSize(board.getLength());
    const blankMap = RenderMap.createRenderMap(boardSize.width, true);
    this.renderer.render(board, blankMap, [], 0);
  }

  protected renderSelected(board: Board, renderMap: boolean[][]) {
    this.renderer.render(board, renderMap, [], 0);
  }

  protected renderFromBoards(oldBoard: Board, newBoard: Board) {
    const renderMap = RenderMap.createRenderMapFromBoards(oldBoard, newBoard);
    this.renderSelected(newBoard, renderMap);
  }

  protected sizeCanvas(boardSize: BoardSize) {
    this.renderer.resize(boardSize);
    this.renderEverything(this.board);
  }

  protected revertEditMessage() {
    const s = setTimeout(() => {
      const message = document.getElementById("message");
      message.innerHTML = "EDIT MODE";
    }, 3000);
  }

  protected showEditMessage(text) {
    const message = document.getElementById("message");
    message.innerHTML = text;
    this.revertEditMessage();
  }

  protected loadLevel(levelID, callback) {
    this.levels.loadLevel(
      levelID,
      (savedLevel: SavedLevel) => {
        const text = "Level " + savedLevel.levelID.toString() + " loaded!";
        this.showEditMessage(text);
        this.board = this.getLevelBoard(savedLevel.board, savedLevel.boardSize);
        this.renderer = this.createRenderer(savedLevel.boardSize);
        callback();
      },
      () => {
        this.board = this.getBlankBoard(this.boardSize);
        this.renderer = this.createRenderer(this.boardSize);
        callback();
      }
    );
  }

  protected bindSizeHandler() {
    window.addEventListener("resize", () => {
      this.sizeCanvas(this.boardSize);
    });
  }

  protected bindClickHandler() {
    const canvas = document.getElementById("canvas");
    canvas.addEventListener("click", event => {
      this.handleDrawEvent(event);
    });
  }

  protected bindMouseMoveHandler() {
    const canvas = document.getElementById("canvas");
    canvas.addEventListener("mousemove", event => {
      if (event.button > 0 || event.buttons > 0) {
        this.handleDrawEvent(event);
      }
    });
  }

  protected handleDrawEvent(event) {
    const tileSize = this.canvas.calcTileSize(this.boardSize);
    const coords = new Coords({
      offsetX: event.offsetX % tileSize - tileSize / 2,
      offsetY: event.offsetY % tileSize - tileSize / 2,
      x: Math.floor(event.offsetX / tileSize),
      y: Math.floor(event.offsetY / tileSize)
    });
    this.drawCurrentTile(coords);
  }

  // coords is always x,y,offsetX, offsetY
  protected drawCurrentTile(coords: Coords) {
    const tileID = this.tileChooser.chosenTileID;
    if (tileID < 1) {
      return false;
    }

    const currentTile = this.board.getTile(coords.x, coords.y);

    const tile = Map.cloneTile(tileID);

    const placedTile = tile.modify({
      x: coords.x,
      y: coords.y
    });

    // if no change, don't bother

    if (currentTile.equals(placedTile)) {
      // don't fill the undo with crap
      return false;
    }

    const oldBoard = this.board;
    const newBoard = oldBoard.modify(coords.x, coords.y, placedTile);

    this.renderFromBoards(oldBoard, newBoard);

    this.updateBoard(newBoard);
  }
}

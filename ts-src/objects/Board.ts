import { fromJS, List } from "immutable";
import { Tile } from "./Tile";

// new board is built from JS array
// all changes reuse the re-generated List object

export class Board {
  protected list: List<List<Tile>>;

  constructor(values: any[], list: List<List<Tile>> = null) {
    if (values) {
      this.list = fromJS(values); // create new
    } else {
      this.list = list; // re-use old
    }
  }

  public toJS() {
    return this.list.toJS();
  }

  public getTile(x: number, y: number): Tile {
    return this.list.getIn([x, y]);
  }

  public modify(x: number, y: number, tile: any): Board {
    const updatedList = this.list.setIn([x, y], tile);
    return new Board(undefined, updatedList);
  }

  public getLength(): number {
    return this.list.count();
  }

  public getAllTiles(): List<Tile> {
    const flat = this.list.flatten(1);
    return flat as List<Tile>;
  }
}

export class BoardSize {
  public height: number;
  public width: number;

  protected minSize: number = 5;
  protected maxSize: number = 40;

  constructor(size: number) {
    if (size < this.minSize) {
      size = this.minSize;
    }
    if (size > this.maxSize) {
      size = this.maxSize;
    }
    this.width = this.height = size;
  }

  public grow(): BoardSize {
    if (this.width < this.maxSize) {
      this.width++;
    }
    if (this.height < this.maxSize) {
      this.height++;
    }
    return new BoardSize(this.width);
  }

  public shrink(): BoardSize {
    if (this.width > this.minSize) {
      this.width--;
    }
    if (this.height > this.minSize) {
      this.height--;
    }
    return new BoardSize(this.width);
  }

  public getData() {
    return {
      height: this.height,
      width: this.width
    };
  }
}

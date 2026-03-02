use crate::matrix::Matrix;
use crate::types::board::{Board, BoardSize};
use crate::types::coord::Coord;
use crate::types::tile::{Tile, TILE_SIZE};

pub fn create_board_size(i: i32) -> BoardSize {
    BoardSize {
        width: i,
        height: i,
    }
}

pub fn get_tile_by_coord(board: &Board, coord: &Coord) -> Tile {
    let w = board.width() as i32;
    let h = board.height() as i32;
    let x = coord.x.rem_euclid(w) as usize;
    let y = coord.y.rem_euclid(h) as usize;
    board.get(x, y).cloned().unwrap_or_else(Tile::empty_tile)
}

pub fn replace_tile(board: &Board, coord: &Coord, tile: Tile) -> Board {
    let x = coord.x as usize;
    let y = coord.y as usize;
    board.set(x, y, tile).unwrap_or_else(|| board.clone())
}

pub fn board_from_array(tiles: &[Vec<Tile>]) -> Board {
    Matrix::from_2d(tiles).unwrap_or_else(Matrix::empty)
}

pub fn board_size_from_board<T: Clone>(board: &Matrix<T>) -> BoardSize {
    BoardSize {
        width: board.width() as i32,
        height: board.height() as i32,
    }
}

pub fn create_centered_translation(size: i32) -> (f64, f64) {
    let half = (size / 2) as f64;
    (half, half)
}

pub fn create_tile_translation(coord: &Coord) -> (f64, f64) {
    let tx = (TILE_SIZE / 2 + coord.total_x()) as f64;
    let ty = (TILE_SIZE / 2 + coord.total_y()) as f64;
    (tx, ty)
}

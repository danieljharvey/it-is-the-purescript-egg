use crate::matrix::Matrix;
use super::tile::Tile;

pub type Board = Matrix<Tile>;
pub type RenderMap = Matrix<bool>;

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct BoardSize {
    pub width: i32,
    pub height: i32,
}

pub struct RenderItem<'a> {
    pub x: usize,
    pub y: usize,
    pub value: &'a Tile,
}

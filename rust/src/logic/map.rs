use crate::data::tile_set::TILES;
use crate::matrix::Matrix;
use crate::types::action::Clockwise;
use crate::types::board::{Board, BoardSize};
use crate::types::coord::Coord;
use crate::types::player::Player;
use crate::types::render_angle::RenderAngle;
use crate::types::tile::Tile;

use super::board::board_size_from_board;

pub fn translate_rotation(size: &BoardSize, coord: &Coord, clockwise: &Clockwise) -> Coord {
    let width = size.width - 1;
    let height = size.height - 1;
    match clockwise {
        Clockwise::Clockwise => Coord {
            x: width - coord.y,
            y: coord.x,
            offset_x: coord.offset_x,
            offset_y: coord.offset_y,
        },
        Clockwise::AntiClockwise => Coord {
            x: coord.y,
            y: height - coord.x,
            offset_x: coord.offset_x,
            offset_y: coord.offset_y,
        },
    }
}

pub fn get_new_player_direction(coord: &Coord, clockwise: &Clockwise) -> Coord {
    if coord.is_stationary() {
        match clockwise {
            Clockwise::Clockwise => Coord::new(1, 0),
            Clockwise::AntiClockwise => Coord::new(-1, 0),
        }
    } else {
        coord.clone()
    }
}

pub fn rotate_board<T: Clone>(clockwise: &Clockwise, board: &Matrix<T>) -> Matrix<T> {
    let size = board_size_from_board(board);
    let items: Vec<_> = board
        .to_indexed_array()
        .into_iter()
        .map(|item| {
            let old_coord = Coord::new(item.x as i32, item.y as i32);
            let new_coord = translate_rotation(&size, &old_coord, clockwise);
            (new_coord.x as usize, new_coord.y as usize, item.value.clone())
        })
        .collect();

    board.indexed_map(|x, y, default| {
        items
            .iter()
            .find(|(nx, ny, _)| *nx == x && *ny == y)
            .map(|(_, _, v)| v.clone())
            .unwrap_or_else(|| default.clone())
    })
}

pub fn change_render_angle(angle: RenderAngle, clockwise: &Clockwise) -> RenderAngle {
    match clockwise {
        Clockwise::Clockwise => angle.increase(RenderAngle(90)),
        Clockwise::AntiClockwise => angle.decrease(RenderAngle(90)),
    }
}

pub fn rotate_player(size: &BoardSize, clockwise: &Clockwise, player: &Player) -> Player {
    let new_coords = translate_rotation(size, &player.coords, clockwise).center();
    let direction = get_new_player_direction(&player.direction, clockwise);
    Player {
        coords: new_coords,
        direction,
        ..player.clone()
    }
}

pub fn rotate_offset(clockwise: &Clockwise, coord: &Coord) -> Coord {
    match clockwise {
        Clockwise::Clockwise => Coord::new_full(0, 0, -coord.offset_y, coord.offset_x),
        Clockwise::AntiClockwise => Coord::new_full(0, 0, coord.offset_y, -coord.offset_x),
    }
}

pub fn switch_tiles(old_id: i32, new_id: i32, board: &Board) -> Board {
    board.map(|tile| switch_tile(old_id, new_id, tile))
}

fn switch_tile(old_id: i32, new_id: i32, tile: &Tile) -> Tile {
    if tile.id == old_id {
        TILES.get(&new_id).cloned().unwrap_or_else(|| tile.clone())
    } else if tile.id == new_id {
        TILES.get(&old_id).cloned().unwrap_or_else(|| tile.clone())
    } else {
        tile.clone()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::data::tile_set::TILES;

    fn size10() -> BoardSize {
        BoardSize {
            width: 10,
            height: 10,
        }
    }

    // --- translateRotation clockwise ---

    #[test]
    fn rotate_cw_0_0() {
        let c = translate_rotation(&size10(), &Coord::new(0, 0), &Clockwise::Clockwise);
        assert_eq!((c.x, c.y), (9, 0));
    }

    #[test]
    fn rotate_cw_9_0() {
        let c = translate_rotation(&size10(), &Coord::new(9, 0), &Clockwise::Clockwise);
        assert_eq!((c.x, c.y), (9, 9));
    }

    #[test]
    fn rotate_cw_9_9() {
        let c = translate_rotation(&size10(), &Coord::new(9, 9), &Clockwise::Clockwise);
        assert_eq!((c.x, c.y), (0, 9));
    }

    #[test]
    fn rotate_cw_0_9() {
        let c = translate_rotation(&size10(), &Coord::new(0, 9), &Clockwise::Clockwise);
        assert_eq!((c.x, c.y), (0, 0));
    }

    // --- translateRotation anticlockwise ---

    #[test]
    fn rotate_acw_0_0() {
        let c = translate_rotation(&size10(), &Coord::new(0, 0), &Clockwise::AntiClockwise);
        assert_eq!((c.x, c.y), (0, 9));
    }

    #[test]
    fn rotate_acw_0_9() {
        let c = translate_rotation(&size10(), &Coord::new(0, 9), &Clockwise::AntiClockwise);
        assert_eq!((c.x, c.y), (9, 9));
    }

    #[test]
    fn rotate_acw_9_9() {
        let c = translate_rotation(&size10(), &Coord::new(9, 9), &Clockwise::AntiClockwise);
        assert_eq!((c.x, c.y), (9, 0));
    }

    #[test]
    fn rotate_acw_9_0() {
        let c = translate_rotation(&size10(), &Coord::new(9, 0), &Clockwise::AntiClockwise);
        assert_eq!((c.x, c.y), (0, 0));
    }

    // --- getNewPlayerDirection ---

    #[test]
    fn direction_unchanged_when_moving() {
        let dir = Coord::new(1, 0);
        assert_eq!(get_new_player_direction(&dir, &Clockwise::Clockwise), dir);
    }

    #[test]
    fn direction_cw_from_stationary() {
        let dir = Coord::new(0, 0);
        assert_eq!(
            get_new_player_direction(&dir, &Clockwise::Clockwise),
            Coord::new(1, 0)
        );
    }

    #[test]
    fn direction_acw_from_stationary() {
        let dir = Coord::new(0, 0);
        assert_eq!(
            get_new_player_direction(&dir, &Clockwise::AntiClockwise),
            Coord::new(-1, 0)
        );
    }

    // --- changeRenderAngle ---

    #[test]
    fn change_angle_cw_full_cycle() {
        let a = change_render_angle(RenderAngle(0), &Clockwise::Clockwise);
        assert_eq!(a, RenderAngle(90));
        let a = change_render_angle(a, &Clockwise::Clockwise);
        assert_eq!(a, RenderAngle(180));
        let a = change_render_angle(a, &Clockwise::Clockwise);
        assert_eq!(a, RenderAngle(270));
        let a = change_render_angle(a, &Clockwise::Clockwise);
        assert_eq!(a, RenderAngle(0));
    }

    #[test]
    fn change_angle_acw_full_cycle() {
        let a = change_render_angle(RenderAngle(0), &Clockwise::AntiClockwise);
        assert_eq!(a, RenderAngle(270));
        let a = change_render_angle(a, &Clockwise::AntiClockwise);
        assert_eq!(a, RenderAngle(180));
        let a = change_render_angle(a, &Clockwise::AntiClockwise);
        assert_eq!(a, RenderAngle(90));
        let a = change_render_angle(a, &Clockwise::AntiClockwise);
        assert_eq!(a, RenderAngle(0));
    }

    // --- rotateOffset ---

    #[test]
    fn rotate_offset_acw() {
        let c = Coord::new_full(0, 0, -10, -5);
        let r = rotate_offset(&Clockwise::AntiClockwise, &c);
        assert_eq!(r, Coord::new_full(0, 0, -5, 10));
    }

    #[test]
    fn rotate_offset_cw() {
        let c = Coord::new_full(0, 0, 10, 5);
        let r = rotate_offset(&Clockwise::Clockwise, &c);
        assert_eq!(r, Coord::new_full(0, 0, -5, 10));
    }

    // --- switchTiles ---

    #[test]
    fn switch_tiles_ignores_irrelevant() {
        let tile2 = TILES.get(&2).unwrap().clone(); // Fabric
        let board = crate::matrix::Matrix::from_2d(&[vec![tile2.clone()]]).unwrap();
        let new_board = switch_tiles(15, 16, &board);
        assert_eq!(new_board.get(0, 0).unwrap().id, 2);
    }

    #[test]
    fn switch_tiles_swaps_one() {
        let tile15 = TILES.get(&15).unwrap().clone();
        let board = crate::matrix::Matrix::from_2d(&[vec![tile15]]).unwrap();
        let new_board = switch_tiles(15, 16, &board);
        assert_eq!(new_board.get(0, 0).unwrap().id, 16);
    }

    #[test]
    fn switch_tiles_swaps_both() {
        let tile15 = TILES.get(&15).unwrap().clone();
        let tile16 = TILES.get(&16).unwrap().clone();
        let board = crate::matrix::Matrix::from_2d(&[vec![tile15, tile16]]).unwrap();
        let new_board = switch_tiles(15, 16, &board);
        assert_eq!(new_board.get(0, 0).unwrap().id, 16);
        assert_eq!(new_board.get(0, 1).unwrap().id, 15);
    }
}

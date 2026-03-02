use crate::matrix::Matrix;
use crate::types::board::{Board, RenderMap};
use crate::types::coord::Coord;
use crate::types::game_state::GameState;
use crate::types::player::Player;
use crate::types::tile::{Tile, TILE_SIZE};

use super::board::board_size_from_board;

pub fn game_states_to_render_map(old: &GameState, new: &GameState) -> RenderMap {
    if needs_full_refresh(old, new) {
        fill_whole_board(true, &new.board)
    } else {
        let board_map = create_render_map(&old.board, &new.board);
        let board_map = add_players_to_render_map(&old.players, &board_map);
        add_players_to_render_map(&new.players, &board_map)
    }
}

fn needs_full_refresh(old: &GameState, new: &GameState) -> bool {
    old.rotate_angle != new.rotate_angle || old.turns == 0
}

fn create_render_map(before: &Board, after: &Board) -> RenderMap {
    before
        .zip_with(after, |a: &Tile, b: &Tile| a != b)
        .unwrap_or_else(|| blank_render_map(before))
}

fn add_players_to_render_map(players: &[Player], r_map: &RenderMap) -> RenderMap {
    let mut map = r_map.clone();
    for player in players {
        map = add_player_to_render_map(player, &map);
    }
    map
}

fn add_player_to_render_map(player: &Player, map: &RenderMap) -> RenderMap {
    let coord_list = get_player_coord_list(map, player);
    let mut result = map.clone();
    for coord in coord_list {
        if let Some(new_map) = result.set(coord.x as usize, coord.y as usize, true) {
            result = new_map;
        }
    }
    result
}

fn get_player_coord_list(map: &RenderMap, player: &Player) -> Vec<Coord> {
    let max_x = map.width() as i32;
    let max_y = map.height() as i32;
    let mut coords = Vec::new();
    for xs in (player.coords.x - 1)..=(player.coords.x + 1) {
        for ys in (player.coords.y - 1)..=(player.coords.y + 1) {
            coords.push(Coord::new(xs.rem_euclid(max_x), ys.rem_euclid(max_y)));
        }
    }
    coords
}

pub fn fill_whole_board(value: bool, board: &Board) -> RenderMap {
    Matrix::repeat(board.width(), board.height(), value)
}

fn blank_render_map(board: &Board) -> RenderMap {
    fill_whole_board(false, board)
}

pub fn get_render_list(r_map: &RenderMap) -> Vec<Coord> {
    r_map
        .to_indexed_array()
        .into_iter()
        .filter(|item| *item.value)
        .map(|item| Coord::new(item.x as i32, item.y as i32))
        .collect()
}

pub fn should_draw_item(map: &RenderMap, x: usize, y: usize, tile: &Tile) -> bool {
    should_draw(map, x, y) && tile.draw_me
}

pub fn should_draw(map: &RenderMap, x: usize, y: usize) -> bool {
    map.get(x, y).copied().unwrap_or(false)
}

pub fn add_edge_players(board: &Board, players: &[Player]) -> Vec<Player> {
    let size = board_size_from_board(board);
    players.iter().flat_map(|p| add_players_for_edge(&size, p)).collect()
}

fn add_players_for_edge(
    size: &crate::types::board::BoardSize,
    player: &Player,
) -> Vec<Player> {
    let height = size.height - 1;
    let width = size.width - 1;
    let mut result = vec![player.clone()];

    if player.coords.total_x() < 0 {
        result.push(Player {
            coords: &player.coords + &Coord::new(width + 1, 0),
            ..player.clone()
        });
    }
    if player.coords.total_x() > width * TILE_SIZE {
        result.push(Player {
            coords: &player.coords + &Coord::new(width + 1, 0).invert(),
            ..player.clone()
        });
    }
    if player.coords.total_y() < 0 {
        result.push(Player {
            coords: &player.coords + &Coord::new(0, height + 1),
            ..player.clone()
        });
    }
    if player.coords.total_y() > height * TILE_SIZE {
        result.push(Player {
            coords: &player.coords + &Coord::new(0, height + 1).invert(),
            ..player.clone()
        });
    }

    result
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::render_angle::RenderAngle;

    fn test_board() -> Board {
        Matrix::repeat(3, 3, Tile::empty_tile())
    }

    #[test]
    fn render_all_after_rotate() {
        let gs = GameState::new(test_board());
        let rotated = GameState {
            rotate_angle: RenderAngle(90),
            ..gs.clone()
        };
        let result = game_states_to_render_map(&gs, &rotated);
        assert_eq!(result, fill_whole_board(true, &test_board()));
    }

    #[test]
    fn render_all_on_turn_zero() {
        let gs = GameState::new(test_board());
        let result = game_states_to_render_map(&gs, &gs);
        assert_eq!(result, fill_whole_board(true, &test_board()));
    }

    // --- addEdgePlayers ---

    #[test]
    fn duplicate_on_left() {
        let player = Player {
            coords: Coord::new_full(0, 0, -30, 0),
            ..Player::default_player()
        };
        let second = Player {
            coords: Coord::new_full(3, 0, -30, 0),
            ..Player::default_player()
        };
        assert_eq!(add_edge_players(&test_board(), &[player.clone()]), vec![player, second]);
    }

    #[test]
    fn duplicate_on_right() {
        let player = Player {
            coords: Coord::new_full(3, 0, 30, 0),
            ..Player::default_player()
        };
        let second = Player {
            coords: Coord::new_full(0, 0, 30, 0),
            ..Player::default_player()
        };
        assert_eq!(add_edge_players(&test_board(), &[player.clone()]), vec![player, second]);
    }

    #[test]
    fn duplicate_on_top() {
        let player = Player {
            coords: Coord::new_full(0, 0, 0, -30),
            ..Player::default_player()
        };
        let second = Player {
            coords: Coord::new_full(0, 3, 0, -30),
            ..Player::default_player()
        };
        assert_eq!(add_edge_players(&test_board(), &[player.clone()]), vec![player, second]);
    }

    #[test]
    fn duplicate_on_bottom() {
        let player = Player {
            coords: Coord::new_full(0, 3, 0, 30),
            ..Player::default_player()
        };
        let second = Player {
            coords: Coord::new_full(0, 0, 0, 30),
            ..Player::default_player()
        };
        assert_eq!(add_edge_players(&test_board(), &[player.clone()]), vec![player, second]);
    }

    #[test]
    fn no_duplicate_when_in_middle() {
        let player = Player {
            coords: Coord::new(1, 1),
            ..Player::default_player()
        };
        assert_eq!(add_edge_players(&test_board(), &[player.clone()]), vec![player]);
    }
}

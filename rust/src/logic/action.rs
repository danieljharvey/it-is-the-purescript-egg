use crate::types::board::Board;
use crate::types::coord::Coord;
use crate::types::game_state::GameState;
use crate::types::outcome::Outcome;
use crate::types::score::Score;
use crate::types::tile::{Tile, TileAction, SwitchColour};

use super::board::{get_tile_by_coord, replace_tile};
use super::map::switch_tiles;

pub(crate) struct TileReturn {
    pub outcome: Outcome,
    pub board: Board,
    pub score: Score,
}

pub fn check_all_actions(gs: &GameState) -> GameState {
    let gs = check_all_tiles_below_player(gs);
    check_all_player_tile_actions(&gs)
}

fn check_all_player_tile_actions(gs: &GameState) -> GameState {
    let players = gs.players.clone();
    let mut result = gs.clone();
    for player in &players {
        let tr = check_player_tile_action(player, &result.board, &result.score, &result.outcome);
        result.outcome = tr.outcome;
        result.board = tr.board;
        result.score = tr.score;
    }
    result
}

pub(crate) fn check_player_tile_action(
    player: &crate::types::player::Player,
    board: &Board,
    score: &Score,
    outcome: &Outcome,
) -> TileReturn {
    match get_player_tile(player, board) {
        Some(tile) => do_tile_action(
            &tile.action,
            &player.coords,
            TileReturn {
                outcome: outcome.clone(),
                board: board.clone(),
                score: *score,
            },
        ),
        None => TileReturn {
            outcome: outcome.clone(),
            board: board.clone(),
            score: *score,
        },
    }
}

fn player_is_over_tile(player: &crate::types::player::Player) -> bool {
    player.coords.is_centered() && player.moved
}

fn get_player_tile(
    player: &crate::types::player::Player,
    board: &Board,
) -> Option<Tile> {
    if player_is_over_tile(player) {
        Some(get_tile_by_coord(board, &player.coords))
    } else {
        None
    }
}

fn do_tile_action(action: &TileAction, coords: &Coord, vals: TileReturn) -> TileReturn {
    match action {
        TileAction::Collectable(i) => collect_item(Score(*i), coords, vals),
        TileAction::CompleteLevel => TileReturn {
            outcome: Outcome::BackAtTheEggCup,
            ..vals
        },
        TileAction::Switch(colour) => do_switch(colour, vals),
        _ => vals,
    }
}

fn collect_item(add_score: Score, coords: &Coord, vals: TileReturn) -> TileReturn {
    let new_board = replace_tile(&vals.board, coords, Tile::empty_tile());
    TileReturn {
        outcome: vals.outcome,
        board: new_board,
        score: vals.score + add_score,
    }
}

fn do_switch(colour: &SwitchColour, vals: TileReturn) -> TileReturn {
    let new_board = match colour {
        SwitchColour::Pink => switch_tiles(15, 16, &vals.board),
        SwitchColour::Green => switch_tiles(18, 19, &vals.board),
    };
    TileReturn {
        board: new_board,
        ..vals
    }
}

fn check_all_tiles_below_player(gs: &GameState) -> GameState {
    let mut board = gs.board.clone();
    for player in &gs.players {
        board = check_tile_below_player(&board, player);
    }
    GameState {
        board,
        ..gs.clone()
    }
}

pub(crate) fn check_tile_below_player(board: &Board, player: &crate::types::player::Player) -> Board {
    let below_coords = &player.coords + &Coord::new(0, 1);
    let below_tile = get_tile_by_coord(board, &below_coords);
    if below_tile.breakable && player.falling {
        replace_tile(board, &below_coords, Tile::empty_tile())
    } else {
        board.clone()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::data::tile_set::TILES;
    use crate::matrix::Matrix;
    use crate::types::player::Player;

    fn collectable_tile() -> Tile {
        Tile {
            action: TileAction::Collectable(100),
            ..Tile::default_tile()
        }
    }

    fn collectable_board() -> Board {
        Matrix::from_2d(&[vec![collectable_tile()]]).unwrap()
    }

    fn complete_level_tile() -> Tile {
        Tile {
            action: TileAction::CompleteLevel,
            ..Tile::default_tile()
        }
    }

    fn complete_board() -> Board {
        Matrix::from_2d(&[vec![complete_level_tile()]]).unwrap()
    }

    fn pink_switch_tile() -> Tile {
        Tile {
            action: TileAction::Switch(SwitchColour::Pink),
            ..Tile::default_tile()
        }
    }

    fn pink_block_tile() -> Tile {
        TILES.get(&15).cloned().unwrap_or_else(Tile::empty_tile)
    }

    fn pink_switch_board() -> Board {
        // 1 column, 2 rows: switch at (0,0), pink block at (0,1)
        Matrix::from_2d(&[vec![pink_switch_tile(), pink_block_tile()]]).unwrap()
    }

    fn crate_tile() -> Tile {
        Tile {
            breakable: true,
            ..Tile::default_tile()
        }
    }

    fn empty_board_2x1() -> Board {
        // 1 column, 2 rows: empty at (0,0), empty at (0,1)
        Matrix::from_2d(&[vec![Tile::empty_tile(), Tile::empty_tile()]]).unwrap()
    }

    fn smashable_board() -> Board {
        // 1 column, 2 rows: empty at (0,0), crate at (0,1)
        Matrix::from_2d(&[vec![Tile::empty_tile(), crate_tile()]]).unwrap()
    }

    fn board_contains_id(id: i32, board: &Board) -> bool {
        board.to_indexed_array().into_iter().any(|item| item.value.id == id)
    }

    // --- checkPlayerTileAction ---

    #[test]
    fn does_nothing_if_not_centered_x() {
        let player = Player {
            coords: Coord::new_full(0, 0, 1, 0),
            ..Player::default_player()
        };
        let result = check_player_tile_action(&player, &collectable_board(), &Score(0), &Outcome::KeepPlaying);
        assert_eq!(result.board, collectable_board());
    }

    #[test]
    fn does_nothing_if_not_centered_y() {
        let player = Player {
            coords: Coord::new_full(0, 0, 0, 1),
            ..Player::default_player()
        };
        let result = check_player_tile_action(&player, &collectable_board(), &Score(0), &Outcome::KeepPlaying);
        assert_eq!(result.board, collectable_board());
    }

    #[test]
    fn does_nothing_if_not_moved() {
        let player = Player {
            coords: Coord::new(0, 0),
            moved: false,
            ..Player::default_player()
        };
        let result = check_player_tile_action(&player, &collectable_board(), &Score(0), &Outcome::KeepPlaying);
        assert_eq!(result.board, collectable_board());
    }

    #[test]
    fn collects_item_when_moved_and_centered() {
        let player = Player {
            coords: Coord::new(0, 0),
            moved: true,
            ..Player::default_player()
        };
        let result = check_player_tile_action(&player, &collectable_board(), &Score(0), &Outcome::KeepPlaying);
        assert_ne!(result.board, collectable_board());
        assert_eq!(result.score, Score(100));
    }

    #[test]
    fn returns_back_at_egg_cup_outcome() {
        let player = Player {
            coords: Coord::new(0, 0),
            moved: true,
            ..Player::default_player()
        };
        let result = check_player_tile_action(&player, &complete_board(), &Score(0), &Outcome::KeepPlaying);
        assert_eq!(result.board, complete_board());
        assert_eq!(result.outcome, Outcome::BackAtTheEggCup);
    }

    #[test]
    fn triggers_pink_switch() {
        let player = Player {
            coords: Coord::new(0, 0),
            moved: true,
            ..Player::default_player()
        };
        let result = check_player_tile_action(&player, &pink_switch_board(), &Score(0), &Outcome::KeepPlaying);
        assert_ne!(result.board, pink_switch_board());
        assert!(board_contains_id(16, &result.board));
    }

    // --- checkTileBelowPlayer ---

    #[test]
    fn does_nothing_when_not_falling() {
        let player = Player {
            coords: Coord::new(0, 0),
            ..Player::default_player()
        };
        let result = check_tile_below_player(&smashable_board(), &player);
        assert_eq!(result, smashable_board());
    }

    #[test]
    fn does_nothing_when_tile_not_smashable() {
        let player = Player {
            coords: Coord::new(0, 0),
            falling: true,
            ..Player::default_player()
        };
        let result = check_tile_below_player(&empty_board_2x1(), &player);
        assert_eq!(result, empty_board_2x1());
    }

    #[test]
    fn smashes_the_crate_below() {
        let player = Player {
            coords: Coord::new(0, 0),
            falling: true,
            ..Player::default_player()
        };
        let result = check_tile_below_player(&smashable_board(), &player);
        assert_eq!(result, empty_board_2x1());
    }
}

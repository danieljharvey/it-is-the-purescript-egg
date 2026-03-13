use crate::types::board::Board;
use crate::types::coord::Coord;
use crate::types::player::{LastAction, Player};
use crate::types::tile::TileAction;

use super::board::get_tile_by_coord;

/// Check all players against the board for split-egg tiles.
/// Players standing centered on a SplitEggs tile are replaced
/// with new eggs heading in each cardinal direction.
pub fn check_board_collisions(board: &Board, players: &[Player]) -> Vec<Player> {
    let mut next_id = players.iter().map(|p| p.id).max().unwrap_or(0) + 1;
    let mut result = Vec::new();

    for player in players {
        if should_split(player, board) {
            let new_players = split_player(player, &mut next_id);
            result.extend(new_players);
        } else {
            result.push(player.clone());
        }
    }

    result
}

fn should_split(player: &Player, board: &Board) -> bool {
    if !player.coords.is_centered() || !player.moved {
        return false;
    }
    if player.player_type.type_.player_value() <= 0 {
        return false;
    }
    let tile = get_tile_by_coord(board, &player.coords);
    matches!(tile.action, TileAction::SplitEggs)
}

fn split_player(player: &Player, next_id: &mut i32) -> Vec<Player> {
    let directions = [
        Coord::new(1, 0),
        Coord::new(-1, 0),
        Coord::new(0, 1),
        Coord::new(0, -1),
    ];

    directions
        .iter()
        .map(|dir| {
            let id = *next_id;
            *next_id += 1;
            Player {
                id,
                direction: dir.clone(),
                last_action: Some(LastAction::Split),
                falling: false,
                ..player.clone()
            }
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::matrix::Matrix;
    use crate::types::current_frame::CurrentFrame;
    use crate::types::player_type::PlayerKind;
    use crate::types::tile::Tile;

    fn splitter_tile() -> Tile {
        Tile {
            action: TileAction::SplitEggs,
            background: true,
            ..Tile::default_tile()
        }
    }

    fn splitter_board() -> Board {
        Matrix::from_2d(&[vec![splitter_tile()]]).unwrap()
    }

    fn empty_board() -> Board {
        Matrix::from_2d(&[vec![Tile::empty_tile()]]).unwrap()
    }

    fn make_egg(x: i32, y: i32) -> Player {
        Player {
            coords: Coord::new(x, y),
            player_type: crate::data::player_types::get_player_type(&PlayerKind::Egg),
            id: 1,
            direction: Coord::new(1, 0),
            old_direction: Coord::new(0, 0),
            current_frame: CurrentFrame::new(18),
            falling: false,
            stop: false,
            last_action: None,
            moved: true,
        }
    }

    fn make_blade(x: i32, y: i32) -> Player {
        Player {
            coords: Coord::new(x, y),
            player_type: crate::data::player_types::get_player_type(&PlayerKind::Blade),
            id: 2,
            direction: Coord::new(1, 0),
            old_direction: Coord::new(0, 0),
            current_frame: CurrentFrame::new(18),
            falling: false,
            stop: false,
            last_action: None,
            moved: true,
        }
    }

    #[test]
    fn splits_egg_on_splitter_tile() {
        let players = vec![make_egg(0, 0)];
        let result = check_board_collisions(&splitter_board(), &players);
        assert_eq!(result.len(), 4);
    }

    #[test]
    fn split_eggs_have_split_last_action() {
        let players = vec![make_egg(0, 0)];
        let result = check_board_collisions(&splitter_board(), &players);
        for p in &result {
            assert_eq!(p.last_action, Some(LastAction::Split));
        }
    }

    #[test]
    fn split_eggs_have_cardinal_directions() {
        let players = vec![make_egg(0, 0)];
        let result = check_board_collisions(&splitter_board(), &players);
        let dirs: Vec<_> = result.iter().map(|p| p.direction.clone()).collect();
        assert!(dirs.contains(&Coord::new(1, 0)));
        assert!(dirs.contains(&Coord::new(-1, 0)));
        assert!(dirs.contains(&Coord::new(0, 1)));
        assert!(dirs.contains(&Coord::new(0, -1)));
    }

    #[test]
    fn split_eggs_have_unique_ids() {
        let players = vec![make_egg(0, 0)];
        let result = check_board_collisions(&splitter_board(), &players);
        let mut ids: Vec<_> = result.iter().map(|p| p.id).collect();
        ids.sort();
        ids.dedup();
        assert_eq!(ids.len(), 4);
    }

    #[test]
    fn does_not_split_on_empty_tile() {
        let players = vec![make_egg(0, 0)];
        let result = check_board_collisions(&empty_board(), &players);
        assert_eq!(result.len(), 1);
    }

    #[test]
    fn does_not_split_non_egg_player() {
        let players = vec![make_blade(0, 0)];
        let result = check_board_collisions(&splitter_board(), &players);
        assert_eq!(result.len(), 1);
    }

    #[test]
    fn does_not_split_when_not_centered() {
        let mut egg = make_egg(0, 0);
        egg.coords = Coord::new_full(0, 0, 5, 0);
        let result = check_board_collisions(&splitter_board(), &[egg]);
        assert_eq!(result.len(), 1);
    }

    #[test]
    fn does_not_split_when_not_moved() {
        let mut egg = make_egg(0, 0);
        egg.moved = false;
        let result = check_board_collisions(&splitter_board(), &[egg]);
        assert_eq!(result.len(), 1);
    }

    #[test]
    fn preserves_other_players() {
        let players = vec![make_egg(0, 0), make_blade(0, 0)];
        let result = check_board_collisions(&splitter_board(), &players);
        // 4 split eggs + 1 blade
        assert_eq!(result.len(), 5);
    }
}

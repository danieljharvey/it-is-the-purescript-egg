use crate::types::board::Board;
use crate::types::coord::Coord;
use crate::types::player::{LastAction, Player};
use crate::types::tile::TileAction;

use super::board::{board_size_from_board, get_tile_by_coord};

const MOVE_DIVISION: i32 = 64;
const SPEED_CONST: i32 = 20;

pub fn move_players(board: &Board, time_passed: i32, players: &[Player]) -> Vec<Player> {
    players
        .iter()
        .map(|p| move_player(board, time_passed, p))
        .collect()
}

fn move_player(board: &Board, time_passed: i32, player: &Player) -> Player {
    let old = player.clone();
    let p = increment_player_direction(time_passed, player);
    let p = correct_player_overflow(&p);
    let p = check_movement_tile(board, &p);
    let p = check_floor_below_player(board, &p);
    let p = check_player_direction(board, &p);
    let p = increment_player_frame(&p);
    let p = correct_player_map_overflow(board, &p);
    mark_player_if_moved(&old, &p)
}

pub(crate) fn calc_move_amount(move_speed: i32, time_passed: i32) -> i32 {
    let move_amount =
        (1.0 / MOVE_DIVISION as f64) * (move_speed as f64) * (SPEED_CONST as f64);
    (move_amount * time_passed as f64).floor() as i32
}

pub(crate) fn increment_player_direction(time_passed: i32, player: &Player) -> Player {
    let move_amount = calc_move_amount(player.player_type.move_speed, time_passed);
    let fall_amount = calc_move_amount(player.player_type.fall_speed, time_passed);

    let new_coords = if player.falling {
        &player.coords + &Coord::create_move_coord(fall_amount, &Coord::new(0, 1))
    } else {
        &player.coords + &Coord::create_move_coord(move_amount, &player.direction)
    };

    Player {
        coords: new_coords,
        ..player.clone()
    }
}

pub(crate) fn correct_player_overflow(player: &Player) -> Player {
    let new_coords = correct_tile_overflow(&player.coords);
    if new_coords == player.coords {
        player.clone()
    } else {
        Player {
            coords: new_coords,
            last_action: None,
            ..player.clone()
        }
    }
}

pub(crate) fn correct_tile_overflow(coord: &Coord) -> Coord {
    if coord.offset_x >= MOVE_DIVISION {
        Coord::new(coord.x + 1, coord.y)
    } else if coord.offset_x <= -MOVE_DIVISION {
        Coord::new(coord.x - 1, coord.y)
    } else if coord.offset_y >= MOVE_DIVISION {
        correct_tile_overflow(&Coord::new(coord.x, coord.y + 1))
    } else if coord.offset_y <= -MOVE_DIVISION {
        correct_tile_overflow(&Coord::new(coord.x, coord.y - 1))
    } else {
        coord.clone()
    }
}

pub(crate) fn correct_player_map_overflow(board: &Board, player: &Player) -> Player {
    let size = board_size_from_board(board);
    let coord = &player.coords;
    let x = coord.x.rem_euclid(size.width);
    let y = coord.y.rem_euclid(size.height);
    Player {
        coords: Coord {
            x,
            y,
            offset_x: coord.offset_x,
            offset_y: coord.offset_y,
        },
        ..player.clone()
    }
}

pub(crate) fn check_floor_below_player(board: &Board, player: &Player) -> Player {
    let can_fall = !player.player_type.flying;
    let below_coord = &player.coords + &Coord::new(0, 1);
    let below_tile = get_tile_by_coord(board, &below_coord);
    let breakable = below_tile.breakable && player.falling;
    let hollow = below_tile.background;

    Player {
        falling: can_fall && (breakable || hollow),
        ..player.clone()
    }
}

pub(crate) fn check_player_direction(board: &Board, player: &Player) -> Player {
    let next_coord = &player.coords + &player.direction;
    let next_tile = get_tile_by_coord(board, &next_coord);

    let new_direction = if next_tile.background || player.falling {
        player.direction.clone()
    } else {
        player.direction.invert()
    };

    Player {
        direction: new_direction,
        ..player.clone()
    }
}

pub(crate) fn check_movement_tile(board: &Board, player: &Player) -> Player {
    if player.last_action == Some(LastAction::Teleported) {
        return player.clone();
    }

    let current_tile = get_tile_by_coord(board, &player.coords);
    if let TileAction::Teleport = current_tile.action {
        let teleports = get_all_teleports(&player.coords, board);
        if let Some(target) = teleports.first() {
            return Player {
                coords: Coord::new(target.0, target.1),
                last_action: Some(LastAction::Teleported),
                ..player.clone()
            };
        }
    }
    player.clone()
}

fn get_all_teleports(coord: &Coord, board: &Board) -> Vec<(i32, i32)> {
    board
        .to_indexed_array()
        .into_iter()
        .filter(|item| {
            item.value.action == TileAction::Teleport
                && !coord.eq_ints(item.x as i32, item.y as i32)
        })
        .map(|item| (item.x as i32, item.y as i32))
        .collect()
}

pub fn is_stationary(coord: &Coord) -> bool {
    coord.is_stationary()
}

pub(crate) fn increment_player_frame(player: &Player) -> Player {
    let p = change_frame_if_moving(player);
    reset_direction_when_stationary(&p)
}

fn change_frame_if_moving(player: &Player) -> Player {
    let dir = &player.direction;
    let new_frame = if dir.x < 0 {
        player.current_frame.dec()
    } else if dir.x > 0 {
        player.current_frame.inc()
    } else if dir.y < 0 {
        player.current_frame.dec()
    } else if dir.y > 0 {
        player.current_frame.inc()
    } else {
        player.current_frame.clone()
    };

    Player {
        current_frame: new_frame,
        ..player.clone()
    }
}

fn reset_direction_when_stationary(player: &Player) -> Player {
    if player.coords.is_stationary() {
        Player {
            old_direction: Coord::new(0, 0),
            ..player.clone()
        }
    } else {
        player.clone()
    }
}

pub(crate) fn mark_player_if_moved(old: &Player, new_player: &Player) -> Player {
    Player {
        moved: old.coords != new_player.coords,
        ..new_player.clone()
    }
}

pub(crate) fn player_has_moved(old: &Player, new_player: &Player) -> bool {
    old.coords != new_player.coords
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::matrix::Matrix;
    use crate::types::current_frame::CurrentFrame;
    use crate::types::player::Player;
    use crate::types::player_type::PlayerType;
    use crate::types::tile::Tile;

    fn bg_tile() -> Tile {
        Tile {
            background: true,
            breakable: false,
            ..Tile::default_tile()
        }
    }

    fn breakable_tile() -> Tile {
        Tile {
            background: false,
            breakable: true,
            ..Tile::default_tile()
        }
    }

    fn teleport_tile() -> Tile {
        Tile {
            action: TileAction::Teleport,
            ..Tile::default_tile()
        }
    }

    fn empty_solid() -> Tile {
        Tile {
            background: false,
            breakable: false,
            ..Tile::default_tile()
        }
    }

    fn board_from(cols: &[Vec<Tile>]) -> Board {
        Matrix::from_2d(cols).unwrap()
    }

    fn default_player() -> Player {
        Player::default_player()
    }

    fn flying_player() -> Player {
        let mut p = default_player();
        p.player_type.flying = true;
        p
    }

    // --- incrementPlayerFrame ---

    #[test]
    fn frame_does_not_change_when_stationary() {
        let p = default_player();
        let new_p = increment_player_frame(&p);
        assert_eq!(new_p.current_frame, p.current_frame);
    }

    #[test]
    fn wipes_old_direction_when_stopped() {
        let p = Player {
            old_direction: Coord::new(1, 0),
            ..default_player()
        };
        let new_p = increment_player_frame(&p);
        assert_eq!(new_p, default_player());
    }

    #[test]
    fn decreases_frame_when_moving_left() {
        let p = Player {
            direction: Coord::new(-1, 0),
            current_frame: CurrentFrame::new(18),
            ..default_player()
        };
        let new_p = increment_player_frame(&p);
        assert_eq!(new_p.current_frame.get(), 17);
    }

    #[test]
    fn increases_frame_when_moving_right() {
        let p = Player {
            direction: Coord::new(1, 0),
            current_frame: CurrentFrame::new(18).dec(),
            ..default_player()
        };
        let new_p = increment_player_frame(&p);
        assert_eq!(new_p.current_frame.get(), 0);
    }

    #[test]
    fn decreases_frame_when_moving_up() {
        let p = Player {
            direction: Coord::new(0, -1),
            current_frame: CurrentFrame::new(18),
            ..default_player()
        };
        let new_p = increment_player_frame(&p);
        assert_eq!(new_p.current_frame.get(), 17);
    }

    #[test]
    fn increases_frame_when_moving_down() {
        let p = Player {
            direction: Coord::new(0, 1),
            current_frame: CurrentFrame::new(18).dec(),
            ..default_player()
        };
        let new_p = increment_player_frame(&p);
        assert_eq!(new_p.current_frame.get(), 0);
    }

    // --- calcMoveAmount ---

    #[test]
    fn calc_move_amount_10_10() {
        assert_eq!(calc_move_amount(10, 10), 31);
    }

    #[test]
    fn calc_move_amount_10_20() {
        assert_eq!(calc_move_amount(10, 20), 62);
    }

    #[test]
    fn calc_move_amount_zero_time() {
        assert_eq!(calc_move_amount(10, 0), 0);
    }

    #[test]
    fn calc_move_amount_zero_speed() {
        assert_eq!(calc_move_amount(0, 10), 0);
    }

    // --- incrementPlayerDirection ---

    #[test]
    fn moves_left() {
        let p = Player {
            direction: Coord::new(-1, 0),
            coords: Coord::new(2, 2),
            ..default_player()
        };
        let expected = calc_move_amount(p.player_type.move_speed, 100);
        let new_p = increment_player_direction(100, &p);
        assert_eq!(new_p.coords.offset_x, -expected);
    }

    #[test]
    fn moves_right() {
        let p = Player {
            direction: Coord::new(1, 0),
            coords: Coord::new(2, 2),
            ..default_player()
        };
        let expected = calc_move_amount(p.player_type.move_speed, 100);
        let new_p = increment_player_direction(100, &p);
        assert_eq!(new_p.coords.offset_x, expected);
    }

    #[test]
    fn moves_up() {
        let p = Player {
            direction: Coord::new(0, -1),
            coords: Coord::new(2, 2),
            ..default_player()
        };
        let expected = calc_move_amount(p.player_type.move_speed, 100);
        let new_p = increment_player_direction(100, &p);
        assert_eq!(new_p.coords.offset_y, -expected);
    }

    #[test]
    fn moves_down() {
        let p = Player {
            direction: Coord::new(0, 1),
            coords: Coord::new(2, 2),
            ..default_player()
        };
        let expected = calc_move_amount(p.player_type.move_speed, 100);
        let new_p = increment_player_direction(100, &p);
        assert_eq!(new_p.coords.offset_y, expected);
    }

    #[test]
    fn zero_speed_stays_still() {
        let p = Player {
            direction: Coord::new(0, 1),
            coords: Coord::new(2, 2),
            player_type: PlayerType {
                move_speed: 0,
                ..PlayerType::default_player_type()
            },
            ..default_player()
        };
        let new_p = increment_player_direction(100, &p);
        assert_eq!(new_p.coords.offset_y, 0);
    }

    #[test]
    fn falls_downwards() {
        let p = Player {
            direction: Coord::new(1, 0),
            coords: Coord::new(2, 2),
            falling: true,
            ..default_player()
        };
        let expected = calc_move_amount(p.player_type.fall_speed, 100);
        let new_p = increment_player_direction(100, &p);
        assert_eq!(new_p.coords.offset_y, expected);
    }

    #[test]
    fn zero_speed_still_falls() {
        let p = Player {
            direction: Coord::new(1, 0),
            coords: Coord::new(2, 2),
            falling: true,
            player_type: PlayerType {
                move_speed: 0,
                fall_speed: 20,
                ..PlayerType::default_player_type()
            },
            ..default_player()
        };
        let expected = calc_move_amount(p.player_type.fall_speed, 100);
        let new_p = increment_player_direction(100, &p);
        assert_eq!(new_p.coords.offset_y, expected);
    }

    // --- correctTileOverflow ---

    #[test]
    fn overflow_no_change_within_boundary() {
        let c = Coord::new_full(1, 0, 54, 0);
        assert_eq!(correct_tile_overflow(&c), c);
    }

    #[test]
    fn overflow_moves_right() {
        let c = Coord::new_full(0, 0, 150, 0);
        assert_eq!(correct_tile_overflow(&c), Coord::new(1, 0));
    }

    #[test]
    fn overflow_moves_left() {
        let c = Coord::new_full(3, 0, -150, 0);
        assert_eq!(correct_tile_overflow(&c), Coord::new(2, 0));
    }

    #[test]
    fn overflow_moves_up() {
        let c = Coord::new_full(0, 4, 0, -150);
        assert_eq!(correct_tile_overflow(&c), Coord::new(0, 3));
    }

    #[test]
    fn overflow_moves_down() {
        let c = Coord::new_full(0, 4, 0, 150);
        assert_eq!(correct_tile_overflow(&c), Coord::new(0, 5));
    }

    // --- correctPlayerOverflow ---

    #[test]
    fn resets_last_action_when_moving_tiles() {
        let p = Player {
            coords: Coord::new_full(1, 1, 150, 0),
            last_action: Some(LastAction::Teleported),
            ..default_player()
        };
        let new_p = correct_player_overflow(&p);
        assert_eq!(new_p.last_action, None);
    }

    // --- correctPlayerMapOverflow ---

    #[test]
    fn map_overflow_no_change_inside() {
        let board = board_from(&[vec![bg_tile(), bg_tile()], vec![bg_tile(), bg_tile()]]);
        let p = Player {
            coords: Coord::new_full(0, 0, 19, 20),
            ..default_player()
        };
        let new_p = correct_player_map_overflow(&board, &p);
        assert_eq!(new_p.coords, p.coords);
    }

    #[test]
    fn map_overflow_corrects_left() {
        let board = board_from(&[vec![bg_tile(), bg_tile()], vec![bg_tile(), bg_tile()]]);
        let p = Player {
            coords: Coord::new_full(-1, 0, 95, 23),
            ..default_player()
        };
        let new_p = correct_player_map_overflow(&board, &p);
        assert_eq!(new_p.coords, Coord::new_full(1, 0, 95, 23));
    }

    #[test]
    fn map_overflow_corrects_right() {
        let board = board_from(&[vec![bg_tile(), bg_tile()], vec![bg_tile(), bg_tile()]]);
        let p = Player {
            coords: Coord::new_full(2, 0, 10, 20),
            ..default_player()
        };
        let new_p = correct_player_map_overflow(&board, &p);
        assert_eq!(new_p.coords, Coord::new_full(0, 0, 10, 20));
    }

    #[test]
    fn map_overflow_corrects_top() {
        let board = board_from(&[vec![bg_tile(), bg_tile()], vec![bg_tile(), bg_tile()]]);
        let p = Player {
            coords: Coord::new_full(0, -1, 12, 22),
            ..default_player()
        };
        let new_p = correct_player_map_overflow(&board, &p);
        assert_eq!(new_p.coords, Coord::new_full(0, 1, 12, 22));
    }

    #[test]
    fn map_overflow_corrects_bottom() {
        let board = board_from(&[vec![bg_tile(), bg_tile()], vec![bg_tile(), bg_tile()]]);
        let p = Player {
            coords: Coord::new(0, 2),
            ..default_player()
        };
        let new_p = correct_player_map_overflow(&board, &p);
        assert_eq!(new_p.coords, Coord::new(0, 0));
    }

    // --- checkFloorBelowPlayer ---

    #[test]
    fn fall_through_breakable_when_already_falling() {
        let board = board_from(&[vec![bg_tile()], vec![breakable_tile()]]);
        let p = Player {
            falling: true,
            ..default_player()
        };
        let new_p = check_floor_below_player(&board, &p);
        assert!(new_p.falling);
    }

    #[test]
    fn dont_fall_through_solid_floor() {
        // 1 column, 2 rows: player at (0,0), solid floor at (0,1)
        let board = board_from(&[vec![bg_tile(), empty_solid()]]);
        let p = Player {
            falling: true,
            ..default_player()
        };
        let new_p = check_floor_below_player(&board, &p);
        assert!(!new_p.falling);
    }

    #[test]
    fn non_flying_falls_through_hollow() {
        let board = board_from(&[vec![bg_tile()], vec![bg_tile()]]);
        let p = Player {
            falling: false,
            ..default_player()
        };
        let new_p = check_floor_below_player(&board, &p);
        assert!(new_p.falling);
    }

    #[test]
    fn flying_player_doesnt_fall() {
        let board = board_from(&[vec![bg_tile()], vec![bg_tile()]]);
        let p = Player {
            falling: true,
            ..flying_player()
        };
        let new_p = check_floor_below_player(&board, &p);
        assert!(!new_p.falling);
    }

    // --- playerHasMoved ---

    #[test]
    fn player_has_not_moved() {
        assert!(!player_has_moved(&default_player(), &default_player()));
    }

    #[test]
    fn player_has_moved_true() {
        let new_p = Player {
            coords: Coord::new(5, 6),
            ..default_player()
        };
        assert!(player_has_moved(&default_player(), &new_p));
    }

    // --- markPlayerIfMoved ---

    #[test]
    fn mark_not_moved() {
        let new_p = mark_player_if_moved(&default_player(), &default_player());
        assert!(!new_p.moved);
    }

    #[test]
    fn mark_has_moved() {
        let new_p = Player {
            coords: Coord::new(5, 6),
            ..default_player()
        };
        let result = mark_player_if_moved(&default_player(), &new_p);
        assert!(result.moved);
    }

    // --- checkPlayerDirection ---

    #[test]
    fn continues_same_direction_no_obstacles() {
        let board = board_from(&[vec![bg_tile(), bg_tile(), bg_tile()]]);
        let p = Player {
            coords: Coord::new(1, 0),
            direction: Coord::new(-1, 0),
            ..default_player()
        };
        assert_eq!(check_player_direction(&board, &p), p);
    }

    #[test]
    fn bounces_off_wall_to_left() {
        let board = board_from(&[vec![empty_solid(), bg_tile(), bg_tile()]]);
        let p = Player {
            coords: Coord::new(1, 0),
            direction: Coord::new(-1, 0),
            ..default_player()
        };
        let expected = Player {
            direction: Coord::new(1, 0),
            ..p.clone()
        };
        assert_eq!(check_player_direction(&board, &p), expected);
    }

    #[test]
    fn doesnt_bounce_when_falling() {
        let board = board_from(&[vec![empty_solid(), bg_tile(), bg_tile()]]);
        let p = Player {
            coords: Coord::new(1, 0),
            direction: Coord::new(-1, 0),
            falling: true,
            ..default_player()
        };
        assert_eq!(check_player_direction(&board, &p), p);
    }

    #[test]
    fn bounces_off_wall_to_right() {
        // 3 columns, 1 row: bg at x=0, bg at x=1, solid wall at x=2
        let board = board_from(&[vec![bg_tile()], vec![bg_tile()], vec![empty_solid()]]);
        let p = Player {
            coords: Coord::new(1, 0),
            direction: Coord::new(1, 0),
            ..default_player()
        };
        let expected = Player {
            direction: Coord::new(-1, 0),
            ..p.clone()
        };
        assert_eq!(check_player_direction(&board, &p), expected);
    }

    #[test]
    fn flying_bounces_off_wall_above() {
        let board = board_from(&[vec![empty_solid(), bg_tile(), bg_tile()]]);
        let p = Player {
            coords: Coord::new(0, 1),
            direction: Coord::new(0, -1),
            ..flying_player()
        };
        let expected = Player {
            direction: Coord::new(0, 1),
            ..p.clone()
        };
        assert_eq!(check_player_direction(&board, &p), expected);
    }

    #[test]
    fn flying_bounces_off_floor_below() {
        // 1 column, 3 rows: bg at y=0, bg at y=1, solid floor at y=2
        let board = board_from(&[vec![bg_tile(), bg_tile(), empty_solid()]]);
        let p = Player {
            coords: Coord::new(0, 1),
            direction: Coord::new(0, 1),
            ..flying_player()
        };
        let expected = Player {
            direction: Coord::new(0, -1),
            ..p.clone()
        };
        assert_eq!(check_player_direction(&board, &p), expected);
    }

    // --- checkMovementTile ---

    #[test]
    fn does_nothing_on_normal_tile() {
        let board = board_from(&[vec![empty_solid(), empty_solid()]]);
        let p = Player {
            coords: Coord::new(0, 0),
            ..default_player()
        };
        assert_eq!(check_movement_tile(&board, &p), p);
    }

    #[test]
    fn stays_with_only_one_teleport() {
        let board = board_from(&[vec![teleport_tile(), empty_solid()]]);
        let p = Player {
            coords: Coord::new(0, 0),
            ..default_player()
        };
        assert_eq!(check_movement_tile(&board, &p), p);
    }

    #[test]
    fn moves_to_other_teleport() {
        // 2 columns, 1 row: teleport at (0,0) and (1,0)
        let board = board_from(&[vec![teleport_tile()], vec![teleport_tile()]]);
        let p = Player {
            coords: Coord::new(0, 0),
            ..default_player()
        };
        let expected = Player {
            coords: Coord::new(1, 0),
            last_action: Some(LastAction::Teleported),
            ..default_player()
        };
        assert_eq!(check_movement_tile(&board, &p), expected);
    }

    #[test]
    fn does_not_move_when_already_teleported() {
        let board = board_from(&[vec![teleport_tile(), teleport_tile()]]);
        let p = Player {
            coords: Coord::new(0, 0),
            last_action: Some(LastAction::Teleported),
            ..default_player()
        };
        assert_eq!(check_movement_tile(&board, &p), p);
    }
}

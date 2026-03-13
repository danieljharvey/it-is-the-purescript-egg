use crate::logic::action as game_action;
use crate::logic::board::board_size_from_board;
use crate::logic::board_collisions;
use crate::logic::collisions;
use crate::logic::create_players::change_player_kind;
use crate::logic::map;
use crate::logic::movement;
use crate::types::action::{Action, Clockwise};
use crate::types::board::Board;
use crate::types::game_state::GameState;
use crate::types::input_event::InputEvent;
use crate::types::outcome::Outcome;
use crate::types::player::Player;
use crate::types::player_type::PlayerKind;
use crate::types::render_angle::RenderAngle;
use crate::types::screen_size::ScreenSize;
use crate::types::tile::TileAction;

const SPIN_SPEED: i32 = 3;

/// Main game tick function. Returns None when level is complete.
pub fn go(time_passed: i32, input: Option<&InputEvent>, gs: &GameState) -> Option<GameState> {
    let next_action = calc_next_action(&gs.current, input);
    let game_state = set_action(&next_action, gs);
    do_action(&game_state, &next_action, time_passed)
}

fn calc_next_action(current: &Action, input: Option<&InputEvent>) -> Action {
    match (current, input) {
        (Action::Turning(c, a), _) => Action::Turning(c.clone(), *a),
        (Action::Playing, Some(InputEvent::Pause)) => Action::Paused,
        (Action::Paused, Some(InputEvent::Pause)) => Action::Playing,
        (Action::Playing, Some(InputEvent::LeftArrow)) => {
            Action::Turning(Clockwise::AntiClockwise, 0)
        }
        (Action::Playing, Some(InputEvent::RightArrow)) => {
            Action::Turning(Clockwise::Clockwise, 0)
        }
        (a, Some(InputEvent::ResizeWindow(x, y))) => {
            Action::Resize(*x, *y, Box::new(a.clone()))
        }
        (a, _) => a.clone(),
    }
}

fn do_action(gs: &GameState, action: &Action, time_passed: i32) -> Option<GameState> {
    match action {
        Action::Paused => Some(gs.clone()),
        Action::Playing if time_passed >= 1 => do_game_move(time_passed, gs),
        Action::Playing => Some(gs.clone()),
        Action::Turning(clockwise, angle) if *angle >= 90 => {
            Some(do_rotate(gs, clockwise))
        }
        Action::Turning(clockwise, angle) => Some(do_turn(clockwise, *angle, gs)),
        Action::Resize(x, y, old_action) => Some(resize_board(*x, *y, old_action, gs)),
    }
}

fn set_action(action: &Action, gs: &GameState) -> GameState {
    GameState {
        current: action.clone(),
        ..gs.clone()
    }
}

fn resize_board(width: i32, height: i32, old_action: &Action, gs: &GameState) -> GameState {
    GameState {
        screen_size: ScreenSize::new(width, height),
        current: old_action.clone(),
        ..gs.clone()
    }
}

fn increment_turn_count(gs: &GameState) -> GameState {
    GameState {
        turns: gs.turns + 1,
        ..gs.clone()
    }
}

fn do_game_move(time_passed: i32, gs: &GameState) -> Option<GameState> {
    let gs = reset_outcome(gs);
    let gs = increment_turn_count(&gs);
    let gs = check_collisions(&gs);
    let gs = do_player_move(time_passed, &gs);
    let gs = check_board_collisions_step(&gs);
    let gs = check_nearly_finished(&gs);
    let gs = game_action::check_all_actions(&gs);
    check_if_completed(&gs)
}

fn check_collisions(gs: &GameState) -> GameState {
    GameState {
        players: collisions::check_all_collisions(&gs.players),
        ..gs.clone()
    }
}

fn check_board_collisions_step(gs: &GameState) -> GameState {
    GameState {
        players: board_collisions::check_board_collisions(&gs.board, &gs.players),
        ..gs.clone()
    }
}

fn do_turn(clockwise: &Clockwise, angle: i32, gs: &GameState) -> GameState {
    let (render_angle, next) = match clockwise {
        Clockwise::Clockwise => (
            RenderAngle(angle),
            Action::Turning(Clockwise::Clockwise, angle + SPIN_SPEED),
        ),
        Clockwise::AntiClockwise => (
            RenderAngle(-angle),
            Action::Turning(Clockwise::AntiClockwise, angle + SPIN_SPEED),
        ),
    };
    GameState {
        render_angle,
        current: next,
        ..gs.clone()
    }
}

fn do_player_move(time_passed: i32, gs: &GameState) -> GameState {
    GameState {
        players: movement::move_players(&gs.board, time_passed, &gs.players),
        ..gs.clone()
    }
}

fn do_rotate(gs: &GameState, clockwise: &Clockwise) -> GameState {
    let board_size = board_size_from_board(&gs.board);
    GameState {
        rotations: gs.rotations + 1,
        board: map::rotate_board(clockwise, &gs.board),
        players: gs
            .players
            .iter()
            .map(|p| map::rotate_player(&board_size, clockwise, p))
            .collect(),
        rotate_angle: map::change_render_angle(gs.rotate_angle, clockwise),
        render_angle: RenderAngle(0),
        current: Action::Playing,
        ..gs.clone()
    }
}

fn reset_outcome(gs: &GameState) -> GameState {
    GameState {
        outcome: Outcome::KeepPlaying,
        ..gs.clone()
    }
}

fn check_if_completed(gs: &GameState) -> Option<GameState> {
    match gs.outcome {
        Outcome::KeepPlaying => Some(gs.clone()),
        Outcome::BackAtTheEggCup => {
            if is_level_done(gs) {
                None
            } else {
                Some(gs.clone())
            }
        }
    }
}

pub(crate) fn check_nearly_finished(gs: &GameState) -> GameState {
    if is_level_done(gs) {
        GameState {
            players: gs.players.iter().map(change_to_rainbow_egg).collect(),
            ..gs.clone()
        }
    } else {
        gs.clone()
    }
}

fn change_to_rainbow_egg(player: &Player) -> Player {
    if is_playable_egg(player) {
        change_player_kind(player, &PlayerKind::RainbowEgg)
    } else {
        player.clone()
    }
}

fn is_level_done(gs: &GameState) -> bool {
    count_players(&gs.players) < 2 && count_collectables(&gs.board) < 1
}

fn is_playable_egg(player: &Player) -> bool {
    player.player_type.type_.player_value() > 0
}

fn count_players(players: &[Player]) -> usize {
    players.iter().filter(|p| is_playable_egg(p)).count()
}

fn count_collectables(board: &Board) -> i32 {
    board
        .to_indexed_array()
        .into_iter()
        .map(|item| match &item.value.action {
            TileAction::Collectable(a) => *a,
            _ => 0,
        })
        .sum()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::data::tile_set::TILES;
    use crate::logic::initialise_level::initialise_game_state;
    use crate::logic::load_level::read_level;
    use crate::matrix::Matrix;
    use crate::types::tile::Tile;

    fn load_test_level(id: i32) -> Option<GameState> {
        let path = format!("../public/levels/{}.json", id);
        let json = std::fs::read_to_string(path).ok()?;
        let level = read_level(&json)?;
        Some(initialise_game_state(level.board))
    }

    fn empty_board(size: usize) -> Board {
        Matrix::repeat(size, size, Tile::empty_tile())
    }

    fn add_tile(id: i32, x: usize, board: &Board) -> Board {
        if let Some(tile) = TILES.get(&id) {
            board.set(x, x, tile.clone()).unwrap_or_else(|| board.clone())
        } else {
            board.clone()
        }
    }

    /// 1 player, no collectables, outcome set to BackAtTheEggCup
    fn test_game_state() -> GameState {
        let board = add_tile(12, 1, &empty_board(10)); // EggCup at (1,1)
        let mut gs = initialise_game_state(board);
        gs.outcome = Outcome::BackAtTheEggCup;
        gs
    }

    /// 2 players + collectables remaining → level not done
    fn game_state_not_finished() -> GameState {
        let board = empty_board(10);
        let board = add_tile(3, 4, &board);   // Cacti (collectable) at (4,4)
        let board = add_tile(12, 3, &board);  // EggCup at (3,3)
        let board = add_tile(12, 2, &board);  // EggCup at (2,2)
        initialise_game_state(board)
    }

    #[test]
    fn test_paused_does_nothing() {
        if let Some(gs) = load_test_level(1) {
            let gs = GameState {
                current: Action::Paused,
                ..gs
            };
            let result = go(10, None, &gs);
            assert!(result.is_some());
            assert_eq!(result.unwrap().turns, gs.turns);
        }
    }

    #[test]
    fn test_playing_with_zero_time() {
        if let Some(gs) = load_test_level(1) {
            let result = go(0, None, &gs);
            assert!(result.is_some());
            assert_eq!(result.unwrap().turns, gs.turns);
        }
    }

    #[test]
    fn test_playing_increments_turns() {
        if let Some(gs) = load_test_level(1) {
            let result = go(1, None, &gs);
            assert!(result.is_some());
            assert_eq!(result.unwrap().turns, gs.turns + 1);
        }
    }

    #[test]
    fn does_not_change_to_rainbow_when_points_remain() {
        let gs = game_state_not_finished();
        let new_gs = check_nearly_finished(&gs);
        assert_eq!(new_gs.players.len(), gs.players.len());
        // Players should not have changed kind
        for (old, new) in gs.players.iter().zip(new_gs.players.iter()) {
            assert_eq!(old.player_type.type_, new.player_type.type_);
        }
    }

    #[test]
    fn changes_egg_to_rainbow_when_no_points_left() {
        let gs = test_game_state();
        let new_gs = check_nearly_finished(&gs);
        assert_eq!(new_gs.players.len(), 1);
        assert_eq!(new_gs.players[0].player_type.type_, PlayerKind::RainbowEgg);
    }
}

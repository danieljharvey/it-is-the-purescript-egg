use crate::logic::create_players::get_players_from_board;
use crate::types::board::Board;
use crate::types::game_state::GameState;

pub fn initialise_game_state(board: Board) -> GameState {
    let players = get_players_from_board(&board);
    let mut gs = GameState::new(board);
    gs.players = players;
    gs
}

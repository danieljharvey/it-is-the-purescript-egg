use super::action::Action;
use super::board::Board;
use super::outcome::Outcome;
use super::player::Player;
use super::render_angle::RenderAngle;
use super::score::Score;
use super::screen_size::ScreenSize;

#[derive(Clone, Debug)]
pub struct GameState {
    pub players: Vec<Player>,
    pub board: Board,
    pub score: Score,
    pub rotations: i32,
    pub rotate_angle: RenderAngle,
    pub render_angle: RenderAngle,
    pub outcome: Outcome,
    pub turns: i32,
    pub current: Action,
    pub screen_size: ScreenSize,
}

impl GameState {
    pub fn new(board: Board) -> Self {
        GameState {
            players: Vec::new(),
            board,
            score: Score(0),
            rotations: 0,
            rotate_angle: RenderAngle(0),
            render_angle: RenderAngle(0),
            outcome: Outcome::KeepPlaying,
            turns: 0,
            current: Action::Playing,
            screen_size: ScreenSize::new(1, 1),
        }
    }
}

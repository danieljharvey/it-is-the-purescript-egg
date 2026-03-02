use super::coord::Coord;
use super::current_frame::CurrentFrame;
use super::player_type::PlayerType;

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum LastAction {
    Split,
    Teleported,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Player {
    pub coords: Coord,
    pub direction: Coord,
    pub old_direction: Coord,
    pub current_frame: CurrentFrame,
    pub id: i32,
    pub falling: bool,
    pub stop: bool,
    pub last_action: Option<LastAction>,
    pub moved: bool,
    pub player_type: PlayerType,
}

impl Player {
    pub fn default_player() -> Self {
        Player {
            coords: Coord::new(0, 0),
            current_frame: CurrentFrame::new(1),
            direction: Coord::new(1, 0),
            falling: false,
            id: 0,
            last_action: None,
            moved: false,
            old_direction: Coord::new(0, 0),
            stop: false,
            player_type: PlayerType::default_player_type(),
        }
    }
}

use crate::data::player_types::PLAYER_TYPES;
use crate::types::board::Board;
use crate::types::coord::Coord;
use crate::types::current_frame::CurrentFrame;
use crate::types::player::Player;
use crate::types::player_type::{PlayerKind, PlayerType};

pub fn get_players_from_board(board: &Board) -> Vec<Player> {
    let items = board.to_indexed_array();
    items
        .into_iter()
        .enumerate()
        .filter_map(|(i, item)| {
            let coord = Coord::new(item.x as i32, item.y as i32);
            let player_kind = item.value.create_player.as_ref()?;
            let player_type = get_player_type_by_kind(player_kind)?;
            Some(create_player(i as i32, coord, player_type))
        })
        .collect()
}

fn get_player_type_by_kind(kind: &PlayerKind) -> Option<PlayerType> {
    PLAYER_TYPES.get(kind).cloned()
}

fn create_player(id: i32, coord: Coord, player_type: PlayerType) -> Player {
    let current_frame = CurrentFrame::new(player_type.frames);
    Player {
        player_type,
        coords: coord,
        direction: Coord::new(1, 0),
        old_direction: Coord::new(0, 0),
        current_frame,
        id,
        falling: false,
        stop: false,
        last_action: None,
        moved: false,
    }
}

pub fn change_player_kind(player: &Player, kind: &PlayerKind) -> Player {
    match get_player_type_by_kind(kind) {
        Some(pt) => Player {
            player_type: pt,
            ..player.clone()
        },
        None => player.clone(),
    }
}

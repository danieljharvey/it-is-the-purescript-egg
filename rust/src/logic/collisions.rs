use crate::data::player_types::get_player_type;
use crate::types::coord::Coord;
use crate::types::player::{LastAction, Player};
use crate::types::player_type::PlayerKind;

const COLLISION_DISTANCE: i32 = 30;

pub fn check_all_collisions(players: &[Player]) -> Vec<Player> {
    let pairs = collided_pairs(players);
    let remaining = remove_collided(&pairs, players);
    let new_players: Vec<Player> = pairs.iter().flat_map(|(a, b)| combine_players(a, b)).collect();
    let mut result = remaining;
    result.extend(new_players);
    result
}

fn collided_pairs(players: &[Player]) -> Vec<(Player, Player)> {
    let mut pairs = Vec::new();
    for i in 0..players.len() {
        for j in (i + 1)..players.len() {
            if check_collision(&players[i], &players[j]) {
                pairs.push((players[i].clone(), players[j].clone()));
            }
        }
    }
    pairs
}

fn check_collision(p1: &Player, p2: &Player) -> bool {
    p1 != p2
        && highest_distance(&p1.coords, &p2.coords) < COLLISION_DISTANCE
        && is_collidable(p1)
        && is_collidable(p2)
        && !just_split(p1)
        && !just_split(p2)
}

fn is_collidable(player: &Player) -> bool {
    !matches!(player.player_type.type_, PlayerKind::SilverEgg)
}

fn just_split(player: &Player) -> bool {
    matches!(player.last_action, Some(LastAction::Split))
}

fn highest_distance(a: &Coord, b: &Coord) -> i32 {
    let diff = a.difference(b);
    let dx = diff.total_x().abs();
    let dy = diff.total_y().abs();
    dx.max(dy)
}

fn remove_collided(pairs: &[(Player, Player)], players: &[Player]) -> Vec<Player> {
    players
        .iter()
        .filter(|p| !in_pairs(pairs, p))
        .cloned()
        .collect()
}

fn in_pairs(pairs: &[(Player, Player)], player: &Player) -> bool {
    pairs
        .iter()
        .any(|(a, b)| player == a || player == b)
}

fn combine_players(p1: &Player, p2: &Player) -> Vec<Player> {
    match get_new_kinds(&p1.player_type.type_, &p2.player_type.type_) {
        Some(kind) => {
            let new_type = get_player_type(&kind);
            vec![Player {
                player_type: new_type,
                ..p1.clone()
            }]
        }
        None => vec![p1.clone(), p2.clone()],
    }
}

fn get_new_kinds(p1: &PlayerKind, p2: &PlayerKind) -> Option<PlayerKind> {
    let sum = p1.player_value() + p2.player_value();
    PlayerKind::from_value(sum)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::current_frame::CurrentFrame;

    fn make_player(kind: PlayerKind, x: i32, y: i32) -> Player {
        Player {
            coords: Coord::new(x, y),
            player_type: crate::data::player_types::get_player_type(&kind),
            id: 0,
            direction: Coord::new(1, 0),
            old_direction: Coord::new(0, 0),
            current_frame: CurrentFrame::new(18),
            falling: false,
            stop: false,
            last_action: None,
            moved: false,
        }
    }

    fn make_player_full(kind: PlayerKind, x: i32, y: i32, ox: i32, oy: i32, id: i32) -> Player {
        Player {
            coords: Coord::new_full(x, y, ox, oy),
            player_type: crate::data::player_types::get_player_type(&kind),
            id,
            direction: Coord::new(1, 0),
            old_direction: Coord::new(0, 0),
            current_frame: CurrentFrame::new(18),
            falling: false,
            stop: false,
            last_action: None,
            moved: false,
        }
    }

    #[test]
    fn test_highest_distance() {
        let a = Coord::new(0, 0);
        let b = Coord::new(1, 0);
        assert_eq!(highest_distance(&a, &b), 64);
    }

    #[test]
    fn test_get_new_kinds() {
        assert_eq!(get_new_kinds(&PlayerKind::Egg, &PlayerKind::Egg), Some(PlayerKind::RedEgg));
        assert_eq!(get_new_kinds(&PlayerKind::Egg, &PlayerKind::RedEgg), Some(PlayerKind::BlueEgg));
        assert_eq!(get_new_kinds(&PlayerKind::RedEgg, &PlayerKind::RedEgg), Some(PlayerKind::YellowEgg));
        assert_eq!(get_new_kinds(&PlayerKind::BlueEgg, &PlayerKind::BlueEgg), None);
    }

    #[test]
    fn check_all_collisions_one_player() {
        let players = vec![make_player(PlayerKind::Egg, 1, 1)];
        let result = check_all_collisions(&players);
        assert_eq!(result.len(), 1);
    }

    #[test]
    fn check_all_collisions_combines_two_at_same_pos() {
        let p1 = make_player_full(PlayerKind::RedEgg, 1, 1, 0, 0, 0);
        let p2 = make_player_full(PlayerKind::RedEgg, 1, 1, 0, 0, 1);
        let result = check_all_collisions(&[p1, p2]);
        assert_eq!(result.len(), 1);
        assert_eq!(result[0].player_type.type_, PlayerKind::YellowEgg);
    }

    #[test]
    fn check_collision_ignores_same_player() {
        let p = make_player(PlayerKind::Egg, 1, 1);
        assert!(!check_collision(&p, &p));
    }

    #[test]
    fn check_collision_same_tile() {
        let p1 = make_player_full(PlayerKind::Egg, 5, 5, 1, 0, 0);
        let p2 = make_player_full(PlayerKind::Egg, 5, 5, 20, 0, 1);
        assert!(check_collision(&p1, &p2));
    }

    #[test]
    fn check_collision_too_far() {
        let p1 = make_player(PlayerKind::Egg, 1, 1);
        let p2 = make_player_full(PlayerKind::Egg, 20, 20, 0, 0, 1);
        assert!(!check_collision(&p1, &p2));
    }

    #[test]
    fn check_collision_close_with_offsets() {
        let p1 = make_player_full(PlayerKind::Egg, 5, 5, 20, 0, 0);
        let p2 = make_player_full(PlayerKind::Egg, 6, 5, -20, 0, 1);
        assert!(check_collision(&p1, &p2));
    }

    #[test]
    fn check_collision_ignores_silver_egg() {
        let p1 = make_player(PlayerKind::Egg, 1, 1);
        let p2 = make_player_full(PlayerKind::SilverEgg, 1, 1, 0, 0, 1);
        assert!(!check_collision(&p1, &p2));
    }

    #[test]
    fn check_collision_ignores_just_split() {
        let mut p1 = make_player(PlayerKind::Egg, 1, 1);
        p1.last_action = Some(LastAction::Split);
        let p2 = make_player_full(PlayerKind::Egg, 1, 1, 0, 0, 1);
        assert!(!check_collision(&p1, &p2));
    }

    #[test]
    fn combine_players_creates_new_kind() {
        let p1 = make_player_full(PlayerKind::RedEgg, 5, 5, 0, 0, 0);
        let p2 = make_player_full(PlayerKind::RedEgg, 5, 5, 0, 0, 1);
        let result = combine_players(&p1, &p2);
        assert_eq!(result.len(), 1);
        assert_eq!(result[0].player_type.type_, PlayerKind::YellowEgg);
        assert_eq!(result[0].id, p1.id); // keeps first player's id
        assert_eq!(result[0].coords, p1.coords); // keeps first player's coords
    }

    #[test]
    fn combine_players_returns_both_when_no_combo() {
        let p1 = make_player_full(PlayerKind::BlueEgg, 5, 5, 0, 0, 0);
        let p2 = make_player_full(PlayerKind::BlueEgg, 5, 5, 0, 0, 1);
        let result = combine_players(&p1, &p2);
        assert_eq!(result.len(), 2);
    }
}

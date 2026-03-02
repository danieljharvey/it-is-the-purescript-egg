use once_cell::sync::Lazy;
use std::collections::HashMap;

use crate::types::player_type::{PlayerKind, PlayerType};
use crate::types::resource_url::ResourceUrl;

pub static PLAYER_TYPES: Lazy<HashMap<PlayerKind, PlayerType>> = Lazy::new(|| {
    let mut m = HashMap::new();

    m.insert(
        PlayerKind::Egg,
        PlayerType {
            frames: 18,
            img: ResourceUrl::SpriteResource("egg-sprite".into()),
            multiplier: 1,
            title: "It is of course the egg".into(),
            type_: PlayerKind::Egg,
            ..PlayerType::default_player_type()
        },
    );

    m.insert(
        PlayerKind::RedEgg,
        PlayerType {
            frames: 18,
            img: ResourceUrl::SpriteResource("egg-sprite-red".into()),
            multiplier: 2,
            title: "It is of course the red egg".into(),
            type_: PlayerKind::RedEgg,
            ..PlayerType::default_player_type()
        },
    );

    m.insert(
        PlayerKind::BlueEgg,
        PlayerType {
            frames: 18,
            img: ResourceUrl::SpriteResource("egg-sprite-blue".into()),
            multiplier: 5,
            title: "It is of course the blue egg".into(),
            type_: PlayerKind::BlueEgg,
            ..PlayerType::default_player_type()
        },
    );

    m.insert(
        PlayerKind::YellowEgg,
        PlayerType {
            frames: 18,
            img: ResourceUrl::SpriteResource("egg-sprite-yellow".into()),
            multiplier: 10,
            title: "It is of course the yellow egg".into(),
            type_: PlayerKind::YellowEgg,
            ..PlayerType::default_player_type()
        },
    );

    m.insert(
        PlayerKind::RainbowEgg,
        PlayerType {
            frames: 18,
            img: ResourceUrl::SpriteResource("egg-rainbow".into()),
            multiplier: 1,
            title: "It goes without saying that this is the rainbow egg".into(),
            type_: PlayerKind::RainbowEgg,
            ..PlayerType::default_player_type()
        },
    );

    m.insert(
        PlayerKind::SilverEgg,
        PlayerType {
            fall_speed: 20,
            frames: 1,
            img: ResourceUrl::SpriteResource("silver-egg".into()),
            move_speed: 0,
            multiplier: 10,
            title: "It is of course the silver egg".into(),
            type_: PlayerKind::SilverEgg,
            ..PlayerType::default_player_type()
        },
    );

    m.insert(
        PlayerKind::Blade,
        PlayerType {
            frames: 18,
            img: ResourceUrl::SpriteResource("blade-sprite".into()),
            title: "It is the mean spirited blade".into(),
            type_: PlayerKind::Blade,
            flying: true,
            ..PlayerType::default_player_type()
        },
    );

    m.insert(
        PlayerKind::FindBlade,
        PlayerType {
            frames: 18,
            img: ResourceUrl::SpriteResource("find-blade-sprite".into()),
            title: "It is the mean spirited blade".into(),
            type_: PlayerKind::FindBlade,
            move_pattern: "seek-egg".into(),
            flying: true,
            ..PlayerType::default_player_type()
        },
    );

    m
});

pub fn get_player_type(kind: &PlayerKind) -> PlayerType {
    PLAYER_TYPES
        .get(kind)
        .cloned()
        .unwrap_or_else(PlayerType::default_player_type)
}

pub fn sprite_resources() -> Vec<ResourceUrl> {
    PLAYER_TYPES.values().map(|pt| pt.img.clone()).collect()
}

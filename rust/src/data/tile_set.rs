use once_cell::sync::Lazy;
use std::collections::HashMap;

use crate::types::player_type::PlayerKind;
use crate::types::resource_url::ResourceUrl;
use crate::types::tile::{Tile, TileAction, SwitchColour};

pub static TILES: Lazy<HashMap<i32, Tile>> = Lazy::new(|| {
    let mut m = HashMap::new();

    m.insert(1, Tile::empty_tile());

    m.insert(
        2,
        Tile {
            background: false,
            id: 2,
            img: ResourceUrl::TileResource("fabric".into()),
            title: "Fabric".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        3,
        Tile {
            background: true,
            action: TileAction::Collectable(1),
            front_layer: true,
            id: 3,
            img: ResourceUrl::TileResource("cacti".into()),
            title: "Cacti".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        4,
        Tile {
            background: true,
            action: TileAction::Collectable(10),
            front_layer: true,
            id: 4,
            img: ResourceUrl::TileResource("plant".into()),
            title: "Plant".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        5,
        Tile {
            background: false,
            breakable: true,
            id: 5,
            img: ResourceUrl::TileResource("crate".into()),
            title: "Crate".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        8,
        Tile {
            background: false,
            id: 8,
            img: ResourceUrl::TileResource("work-surface-2".into()),
            title: "Work surface 2".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        9,
        Tile {
            background: false,
            id: 9,
            img: ResourceUrl::TileResource("work-surface-3".into()),
            title: "Work surface 3".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        10,
        Tile {
            background: false,
            id: 10,
            img: ResourceUrl::TileResource("work-surface-4".into()),
            title: "Work surface 4".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        11,
        Tile {
            background: false,
            id: 11,
            img: ResourceUrl::TileResource("tile".into()),
            title: "Tiles".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        12,
        Tile {
            action: TileAction::CompleteLevel,
            background: true,
            create_player: Some(PlayerKind::Egg),
            front_layer: true,
            id: 12,
            img: ResourceUrl::TileResource("egg-cup".into()),
            title: "Egg Cup".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        13,
        Tile {
            background: true,
            action: TileAction::Collectable(100),
            dont_add: true,
            front_layer: true,
            id: 13,
            img: ResourceUrl::TileResource("toast".into()),
            title: "Toast".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        14,
        Tile {
            action: TileAction::Teleport,
            background: true,
            front_layer: true,
            id: 14,
            img: ResourceUrl::TileResource("door".into()),
            title: "Door".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        15,
        Tile {
            background: true,
            front_layer: true,
            id: 15,
            img: ResourceUrl::TileResource("pink-door-open".into()),
            title: "Pink door open".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        16,
        Tile {
            background: false,
            id: 16,
            img: ResourceUrl::TileResource("pink-door".into()),
            title: "Pink door closed".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        17,
        Tile {
            action: TileAction::Switch(SwitchColour::Pink),
            background: true,
            front_layer: true,
            id: 17,
            img: ResourceUrl::TileResource("pink-switch".into()),
            title: "Pink door switch".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        18,
        Tile {
            background: true,
            front_layer: true,
            id: 18,
            img: ResourceUrl::TileResource("green-door-open".into()),
            title: "Green door open".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        19,
        Tile {
            background: false,
            id: 19,
            img: ResourceUrl::TileResource("green-door".into()),
            title: "Green door closed".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        20,
        Tile {
            action: TileAction::Switch(SwitchColour::Green),
            background: true,
            front_layer: true,
            id: 20,
            img: ResourceUrl::TileResource("green-switch".into()),
            title: "Green door switch".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        21,
        Tile {
            background: true,
            create_player: Some(PlayerKind::SilverEgg),
            front_layer: true,
            id: 21,
            img: ResourceUrl::TileResource("silver-egg-cup".into()),
            title: "Silver Egg Cup".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        22,
        Tile {
            background: true,
            create_player: Some(PlayerKind::Blade),
            front_layer: true,
            id: 22,
            img: ResourceUrl::TileResource("blade-egg-cup".into()),
            title: "Blade egg cup".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        23,
        Tile {
            background: true,
            create_player: Some(PlayerKind::FindBlade),
            front_layer: true,
            id: 23,
            img: ResourceUrl::TileResource("find-blade-egg-cup".into()),
            title: "Find-blade egg cup".into(),
            ..Tile::default_tile()
        },
    );

    m.insert(
        24,
        Tile {
            background: true,
            id: 24,
            action: TileAction::SplitEggs,
            front_layer: true,
            img: ResourceUrl::TileResource("egg-splitter".into()),
            title: "It is the egg splitter".into(),
            ..Tile::default_tile()
        },
    );

    m
});

pub fn tile_resources() -> Vec<ResourceUrl> {
    TILES.values().map(|t| t.img.clone()).collect()
}

pub fn get_tile_by_id(id: i32) -> Tile {
    TILES.get(&id).cloned().unwrap_or_else(Tile::empty_tile)
}

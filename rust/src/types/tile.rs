use super::player_type::PlayerKind;
use super::resource_url::ResourceUrl;

pub const TILE_SIZE: i32 = 64;

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum SwitchColour {
    Pink,
    Green,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum TileAction {
    NoOp,
    Collectable(i32),
    CompleteLevel,
    Switch(SwitchColour),
    Teleport,
    SplitEggs,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Tile {
    pub id: i32,
    pub title: String,
    pub img: ResourceUrl,
    pub draw_me: bool,
    pub background: bool,
    pub front_layer: bool,
    pub breakable: bool,
    pub action: TileAction,
    pub dont_add: bool,
    pub create_player: Option<PlayerKind>,
}

impl Tile {
    pub fn default_tile() -> Self {
        Tile {
            action: TileAction::NoOp,
            draw_me: true,
            background: false,
            breakable: false,
            create_player: None,
            dont_add: false,
            front_layer: false,
            id: 0,
            img: ResourceUrl::TileResource("sky".into()),
            title: "Title".into(),
        }
    }

    pub fn empty_tile() -> Self {
        Tile {
            background: true,
            draw_me: false,
            id: 1,
            img: ResourceUrl::TileResource("sky".into()),
            title: "Title".into(),
            ..Self::default_tile()
        }
    }
}

/// JSON tile from level files - only has an id
#[derive(Clone, Debug, serde::Deserialize)]
pub struct JsonTile {
    pub id: i32,
}

use super::resource_url::ResourceUrl;

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum PlayerKind {
    Egg,
    RedEgg,
    BlueEgg,
    YellowEgg,
    RainbowEgg,
    SilverEgg,
    Blade,
    FindBlade,
}

impl PlayerKind {
    pub fn player_value(&self) -> i32 {
        match self {
            PlayerKind::Egg => 1,
            PlayerKind::RedEgg => 2,
            PlayerKind::BlueEgg => 3,
            PlayerKind::YellowEgg => 4,
            _ => 0,
        }
    }

    pub fn from_value(v: i32) -> Option<PlayerKind> {
        match v {
            1 => Some(PlayerKind::Egg),
            2 => Some(PlayerKind::RedEgg),
            3 => Some(PlayerKind::BlueEgg),
            4 => Some(PlayerKind::YellowEgg),
            _ => None,
        }
    }
}

impl std::fmt::Display for PlayerKind {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            PlayerKind::Egg => write!(f, "Egg"),
            PlayerKind::RedEgg => write!(f, "Red Egg"),
            PlayerKind::BlueEgg => write!(f, "Blue Egg"),
            PlayerKind::YellowEgg => write!(f, "Yellow Egg"),
            PlayerKind::RainbowEgg => write!(f, "Rainbow Egg"),
            PlayerKind::SilverEgg => write!(f, "Silver Egg"),
            PlayerKind::Blade => write!(f, "Blade"),
            PlayerKind::FindBlade => write!(f, "Find Blade"),
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct PlayerType {
    pub frames: i32,
    pub img: ResourceUrl,
    pub multiplier: i32,
    pub title: String,
    pub type_: PlayerKind,
    pub fall_speed: i32,
    pub move_speed: i32,
    pub flying: bool,
    pub move_pattern: String,
}

impl PlayerType {
    pub fn default_player_type() -> Self {
        PlayerType {
            frames: 18,
            img: ResourceUrl::SpriteResource("egg-sprite".into()),
            multiplier: 1,
            title: "The Egg".into(),
            type_: PlayerKind::Egg,
            fall_speed: 1,
            move_speed: 1,
            flying: false,
            move_pattern: "normal".into(),
        }
    }
}

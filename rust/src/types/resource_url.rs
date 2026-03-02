#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum ResourceUrl {
    TileResource(String),
    SpriteResource(String),
    LevelResource(i32),
    RemoteLevelResource(String),
}

impl std::fmt::Display for ResourceUrl {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ResourceUrl::TileResource(path) => write!(f, "/img/tiles/{}.png", path),
            ResourceUrl::SpriteResource(path) => write!(f, "/img/sprites/{}.png", path),
            ResourceUrl::LevelResource(num) => write!(f, "/levels/{}.json", num),
            ResourceUrl::RemoteLevelResource(url) => write!(f, "{}", url),
        }
    }
}

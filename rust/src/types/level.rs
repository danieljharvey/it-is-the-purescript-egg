use super::board::{Board, BoardSize};

#[derive(Clone, Debug)]
pub struct Level {
    pub board: Board,
    pub board_size: BoardSize,
    pub level_id: i32,
}

/// JSON level structure from level files
#[derive(Clone, Debug, serde::Deserialize)]
pub struct JsonLevel {
    pub board: Vec<Vec<JsonTileEntry>>,
    #[serde(rename = "boardSize")]
    pub board_size: JsonBoardSize,
    #[serde(rename = "levelID")]
    pub level_id: i32,
}

#[derive(Clone, Debug, serde::Deserialize)]
pub struct JsonBoardSize {
    pub width: i32,
    pub height: i32,
}

/// Each tile in the JSON can have many fields but we only need `id`
#[derive(Clone, Debug, serde::Deserialize)]
pub struct JsonTileEntry {
    pub id: i32,
}

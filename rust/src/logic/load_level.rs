use crate::data::tile_set::get_tile_by_id;
use crate::matrix::Matrix;
use crate::types::board::{Board, BoardSize};
use crate::types::level::{JsonLevel, Level};
use crate::types::tile::Tile;

pub fn read_level_json(s: &str) -> Option<JsonLevel> {
    serde_json::from_str(s).ok()
}

pub fn read_level(s: &str) -> Option<Level> {
    let json_level = read_level_json(s)?;
    convert(&json_level)
}

fn convert(json: &JsonLevel) -> Option<Level> {
    let board = create_board(&json.board)?;
    let board_size = BoardSize {
        width: json.board_size.width,
        height: json.board_size.height,
    };
    // Validate dimensions
    if board_size.width != board.width() as i32 || board_size.height != board.height() as i32 {
        return None;
    }
    Some(Level {
        board,
        board_size,
        level_id: json.level_id,
    })
}

fn create_board(json_board: &[Vec<crate::types::level::JsonTileEntry>]) -> Option<Board> {
    if json_board.is_empty() {
        return None;
    }
    let cols: Vec<Vec<Tile>> = json_board
        .iter()
        .map(|col| col.iter().map(|jt| get_tile_by_id(jt.id)).collect())
        .collect();
    Matrix::from_2d(&cols)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read_level_json_basic() {
        let json = r#"{
            "board": [[{"id": 1}, {"id": 2}], [{"id": 3}, {"id": 1}]],
            "boardSize": {"width": 2, "height": 2},
            "levelID": 1
        }"#;
        let level = read_level(json);
        assert!(level.is_some());
        let level = level.unwrap();
        assert_eq!(level.level_id, 1);
        assert_eq!(level.board_size.width, 2);
        assert_eq!(level.board_size.height, 2);
    }

    fn load_level_file(id: i32) -> String {
        let path = format!("../public/levels/{}.json", id);
        std::fs::read_to_string(path).unwrap_or_default()
    }

    #[test]
    fn can_load_files_1_to_19() {
        for i in 1..=19 {
            let json = load_level_file(i);
            assert!(json.len() > 0, "Level {} file should not be empty", i);
        }
    }

    #[test]
    fn can_read_level_json_1_to_19() {
        for i in 1..=19 {
            let json = load_level_file(i);
            assert!(
                read_level_json(&json).is_some(),
                "Level {} should parse as JSON",
                i
            );
        }
    }

    #[test]
    fn can_read_level_1_to_19() {
        for i in 1..=19 {
            let json = load_level_file(i);
            assert!(
                read_level(&json).is_some(),
                "Level {} should parse as a full Level",
                i
            );
        }
    }
}

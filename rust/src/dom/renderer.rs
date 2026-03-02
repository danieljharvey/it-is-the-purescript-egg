use wasm_bindgen::prelude::*;

use crate::logic::board::board_size_from_board;
use crate::logic::map;
use crate::logic::render_map::{
    add_edge_players, game_states_to_render_map, get_render_list, should_draw_item,
};
use crate::types::action::Clockwise;
use crate::types::board::{Board, BoardSize, RenderMap};
use crate::types::coord::Coord;
use crate::types::game_state::GameState;
use crate::types::player::Player;
use crate::types::render_angle::RenderAngle;

use super::canvas::{self, CanvasData};

pub fn render_game_state(
    canvas_data: &mut CanvasData,
    old: &GameState,
    new: &GameState,
) -> Result<(), JsValue> {
    let render_map =
        get_board_for_render_map(new.rotate_angle, &game_states_to_render_map(old, new));

    // Resize if needed
    if old.screen_size != new.screen_size {
        let size = new.screen_size.smallest() as f64;
        canvas::size_canvas(&canvas_data.screen.element, size);
    }
    canvas_data.screen.size = new.screen_size.smallest();

    // Clear dirty tiles
    let clear_list = get_render_list(&render_map);
    for coord in &clear_list {
        canvas::clear_tile(&canvas_data.buffer.context, coord);
    }

    // Render board
    let board = get_board_for_render(new.rotate_angle, &new.board);
    render_board(canvas_data, &render_map, &board)?;

    // Render players
    let players = get_players_for_render(new.rotate_angle, &new.board, &new.players);
    render_players(canvas_data, new.rotate_angle, &new.board, &players)?;

    // Copy buffer to screen
    let angle = calc_render_angle(new);
    canvas::copy_buffer_to_canvas(&canvas_data.buffer, &canvas_data.screen, angle)?;

    Ok(())
}

fn get_board_for_render(angle: RenderAngle, board: &Board) -> Board {
    match angle.0 {
        90 => map::rotate_board(&Clockwise::AntiClockwise, board),
        180 => {
            let b = map::rotate_board(&Clockwise::AntiClockwise, board);
            map::rotate_board(&Clockwise::AntiClockwise, &b)
        }
        270 => map::rotate_board(&Clockwise::Clockwise, board),
        _ => board.clone(),
    }
}

fn get_board_for_render_map(angle: RenderAngle, render_map: &RenderMap) -> RenderMap {
    match angle.0 {
        90 => map::rotate_board(&Clockwise::AntiClockwise, render_map),
        180 => {
            let m = map::rotate_board(&Clockwise::AntiClockwise, render_map);
            map::rotate_board(&Clockwise::AntiClockwise, &m)
        }
        270 => map::rotate_board(&Clockwise::Clockwise, render_map),
        _ => render_map.clone(),
    }
}

fn get_players_for_render(
    angle: RenderAngle,
    board: &Board,
    players: &[Player],
) -> Vec<Player> {
    let size = board_size_from_board(board);
    match angle.0 {
        90 => players
            .iter()
            .map(|p| rotate_player_for_render(&size, &Clockwise::AntiClockwise, p))
            .collect(),
        180 => {
            let p1: Vec<Player> = players
                .iter()
                .map(|p| rotate_player_for_render(&size, &Clockwise::AntiClockwise, p))
                .collect();
            p1.iter()
                .map(|p| rotate_player_for_render(&size, &Clockwise::AntiClockwise, p))
                .collect()
        }
        270 => players
            .iter()
            .map(|p| rotate_player_for_render(&size, &Clockwise::Clockwise, p))
            .collect(),
        _ => players.to_vec(),
    }
}

fn rotate_player_for_render(
    size: &BoardSize,
    clockwise: &Clockwise,
    player: &Player,
) -> Player {
    let rotated = map::rotate_player(size, clockwise, player);
    let rotated_offset = map::rotate_offset(clockwise, &player.coords);
    Player {
        coords: &rotated.coords + &rotated_offset,
        ..rotated
    }
}

fn calc_render_angle(gs: &GameState) -> RenderAngle {
    gs.render_angle + gs.rotate_angle
}

fn render_board(
    canvas_data: &CanvasData,
    render_map: &RenderMap,
    board: &Board,
) -> Result<(), JsValue> {
    let items = board.to_indexed_array();
    for item in items {
        if should_draw_item(render_map, item.x, item.y, item.value) {
            if let Some(img) = canvas_data.image_map.get(&item.value.img) {
                let coord = Coord::new(item.x as i32, item.y as i32);
                canvas::draw_tile(&canvas_data.buffer.context, img, &coord)?;
            }
        }
    }
    Ok(())
}

fn render_players(
    canvas_data: &CanvasData,
    angle: RenderAngle,
    board: &Board,
    players: &[Player],
) -> Result<(), JsValue> {
    let all_players = add_edge_players(board, players);
    for player in &all_players {
        if let Some(img) = canvas_data.image_map.get(&player.player_type.img) {
            canvas::draw_player(
                &canvas_data.buffer.context,
                img,
                angle,
                &player.coords,
                player.current_frame.get(),
            )?;
        }
    }
    Ok(())
}

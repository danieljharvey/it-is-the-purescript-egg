use std::collections::HashMap;
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;
use web_sys::{
    CanvasRenderingContext2d, HtmlCanvasElement, HtmlImageElement,
};

use crate::types::coord::Coord;
use crate::types::render_angle::RenderAngle;
use crate::types::resource_url::ResourceUrl;
use crate::types::tile::TILE_SIZE;

pub const BUFFER_SIZE: i32 = 640;
pub const CANVAS_SIZE: i32 = 480;

pub struct CanvasInfo {
    pub element: HtmlCanvasElement,
    pub context: CanvasRenderingContext2d,
    pub size: i32,
}

pub type ImageSourceMap = HashMap<ResourceUrl, HtmlImageElement>;

pub struct CanvasData {
    pub buffer: CanvasInfo,
    pub screen: CanvasInfo,
    pub image_map: ImageSourceMap,
}

fn get_canvas(id: &str) -> Result<HtmlCanvasElement, JsValue> {
    let document = web_sys::window()
        .ok_or("no window")?
        .document()
        .ok_or("no document")?;
    document
        .get_element_by_id(id)
        .ok_or_else(|| JsValue::from_str(&format!("no element #{}", id)))?
        .dyn_into::<HtmlCanvasElement>()
        .map_err(|_| JsValue::from_str("not a canvas"))
}

pub fn setup_canvas_sync() -> Result<(CanvasInfo, CanvasInfo), JsValue> {
    let buffer_el = get_canvas("buffer-canvas")?;
    let buffer_ctx = buffer_el
        .get_context("2d")?
        .ok_or("no 2d context")?
        .dyn_into::<CanvasRenderingContext2d>()?;

    let screen_el = get_canvas("canvas")?;
    let screen_ctx = screen_el
        .get_context("2d")?
        .ok_or("no 2d context")?
        .dyn_into::<CanvasRenderingContext2d>()?;

    Ok((
        CanvasInfo {
            element: buffer_el,
            context: buffer_ctx,
            size: BUFFER_SIZE,
        },
        CanvasInfo {
            element: screen_el,
            context: screen_ctx,
            size: CANVAS_SIZE,
        },
    ))
}

pub fn size_canvas(element: &HtmlCanvasElement, size: f64) {
    element.set_width(size as u32);
    element.set_height(size as u32);
}

pub fn clear_tile(context: &CanvasRenderingContext2d, coord: &Coord) {
    let x = (coord.x * TILE_SIZE) as f64;
    let y = (coord.y * TILE_SIZE) as f64;
    let s = TILE_SIZE as f64;
    context.clear_rect(x, y, s, s);
}

pub fn draw_tile(
    context: &CanvasRenderingContext2d,
    image: &HtmlImageElement,
    coord: &Coord,
) -> Result<(), JsValue> {
    let x = coord.total_x() as f64;
    let y = coord.total_y() as f64;
    context.draw_image_with_html_image_element(image, x, y)
}

pub fn draw_player(
    context: &CanvasRenderingContext2d,
    image: &HtmlImageElement,
    angle: RenderAngle,
    coord: &Coord,
    frame: i32,
) -> Result<(), JsValue> {
    let tile_size = TILE_SIZE as f64;
    let half = tile_size / 2.0;

    // translate to tile center
    let tx = (TILE_SIZE / 2 + coord.total_x()) as f64;
    let ty = (TILE_SIZE / 2 + coord.total_y()) as f64;

    context.save();
    context.translate(tx, ty)?;

    // counter-rotate so player stays upright
    let rad = angle.invert().to_radians();
    context.rotate(rad)?;

    // draw sprite frame
    let sx = (frame * TILE_SIZE) as f64;
    context.draw_image_with_html_image_element_and_sw_and_sh_and_dx_and_dy_and_dw_and_dh(
        image,
        sx,
        0.0,
        tile_size,
        tile_size,
        -half,
        -half,
        tile_size,
        tile_size,
    )?;

    context.restore();
    Ok(())
}

pub fn copy_buffer_to_canvas(
    buffer: &CanvasInfo,
    screen: &CanvasInfo,
    angle: RenderAngle,
) -> Result<(), JsValue> {
    let size = screen.size as f64;
    let half = size / 2.0;

    // Draw gradient background
    let gradient = super::gradient::create_gradient(screen.size, &screen.context)?;
    screen.context.set_fill_style_canvas_gradient(&gradient);
    screen.context.fill_rect(0.0, 0.0, size, size);

    // Darken
    screen.context.set_global_alpha(0.4);
    screen.context.fill_rect(0.0, 0.0, size, size);
    screen.context.set_global_alpha(1.0);
    screen.context.set_fill_style_str("black");

    // Translate to center, rotate, draw buffer
    screen.context.save();
    screen.context.translate(half, half)?;

    let rad = angle.to_radians();
    screen.context.rotate(rad)?;

    let offset = -half;
    screen
        .context
        .draw_image_with_html_canvas_element_and_dw_and_dh(
            &buffer.element,
            offset,
            offset,
            size,
            size,
        )?;

    screen.context.restore();
    Ok(())
}

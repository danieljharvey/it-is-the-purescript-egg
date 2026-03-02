use wasm_bindgen::prelude::*;
use web_sys::{CanvasGradient, CanvasRenderingContext2d};

pub fn create_gradient(
    size: i32,
    context: &CanvasRenderingContext2d,
) -> Result<CanvasGradient, JsValue> {
    let half = (size / 2) as f64;
    let full = size as f64;
    let gradient = context.create_linear_gradient(half, 0.0, half, full);
    gradient.add_color_stop(1.0, "#152b26")?;
    gradient.add_color_stop(0.8, "#102029")?;
    gradient.add_color_stop(0.6, "#192b34")?;
    gradient.add_color_stop(0.0, "#dd8888")?;
    Ok(gradient)
}

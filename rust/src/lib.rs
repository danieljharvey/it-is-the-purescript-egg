use std::cell::RefCell;
use std::rc::Rc;
use wasm_bindgen::prelude::*;

mod data;
mod dom;
mod logic;
pub mod matrix;
pub mod types;

use data::player_types::sprite_resources;
use data::tile_set::tile_resources;
use dom::canvas::{self, CanvasData};
use dom::events::{self, InputEventRef};
use dom::loader;
use logic::initialise_level::initialise_game_state;
use types::level::Level;
use types::resource_url::ResourceUrl;

#[wasm_bindgen(start)]
pub async fn main() -> Result<(), JsValue> {
    console_error_panic_hook::set_once();

    web_sys::console::log_1(&"It Is The Egg (Rust/WASM) starting...".into());

    let game_mode = get_game_mode();

    match game_mode {
        GameMode::Regular => setup_regular_game().await?,
        GameMode::LevelTest(url) => setup_test_game(&url).await?,
    }

    Ok(())
}

enum GameMode {
    Regular,
    LevelTest(String),
}

fn get_game_mode() -> GameMode {
    let window = web_sys::window().unwrap();
    let location = window.location();
    if let Ok(search) = location.search() {
        let params = web_sys::UrlSearchParams::new_with_str(&search).unwrap();
        if let Some(url) = params.get("url") {
            if !url.is_empty() {
                return GameMode::LevelTest(url);
            }
        }
    }
    GameMode::Regular
}

fn image_resources() -> Vec<ResourceUrl> {
    let mut resources = tile_resources();
    resources.extend(sprite_resources());
    resources
}

async fn setup_canvas() -> Result<CanvasData, JsValue> {
    let (buffer, screen) = canvas::setup_canvas_sync()?;
    let image_map = loader::load_all_images(&image_resources()).await?;
    Ok(CanvasData {
        buffer,
        screen,
        image_map,
    })
}

async fn setup_regular_game() -> Result<(), JsValue> {
    let canvas_data = setup_canvas().await?;
    start_new_level(Rc::new(RefCell::new(canvas_data))).await
}

async fn setup_test_game(url: &str) -> Result<(), JsValue> {
    let canvas_data = setup_canvas().await?;
    if let Some(level) = loader::load_level_from_url(url).await {
        let cd = Rc::new(RefCell::new(canvas_data));
        start(cd, &level, Box::new(|| {}))?;
    }
    Ok(())
}

async fn start_new_level(canvas_data: Rc<RefCell<CanvasData>>) -> Result<(), JsValue> {
    let level_id = random_level_id();
    web_sys::console::log_1(&format!("Loading level {}...", level_id).into());

    if let Some(level) = loader::load_level(level_id).await {
        let cd = canvas_data.clone();
        let on_complete = {
            let cd2 = canvas_data.clone();
            Box::new(move || {
                let cd3 = cd2.clone();
                wasm_bindgen_futures::spawn_local(async move {
                    let _ = start_new_level(cd3).await;
                });
            })
        };
        start(cd, &level, on_complete)?;
    }
    Ok(())
}

fn start(
    canvas_data: Rc<RefCell<CanvasData>>,
    level: &Level,
    on_complete: Box<dyn Fn()>,
) -> Result<(), JsValue> {
    let board_pixel_size = level.board_size.width as f64 * 64.0;

    {
        let cd = canvas_data.borrow();
        canvas::size_canvas(&cd.buffer.element, board_pixel_size);
        canvas::size_canvas(&cd.screen.element, board_pixel_size);
    }

    let game_state = initialise_game_state(level.board.clone());
    let gs_ref = Rc::new(RefCell::new(game_state));
    let input_ref: InputEventRef = Rc::new(RefCell::new(None));

    dom::animation_loop::start_animation_loop(
        canvas_data,
        gs_ref,
        input_ref.clone(),
        Rc::from(on_complete),
    );

    events::setup_events(&input_ref)?;
    Ok(())
}

fn random_level_id() -> i32 {
    let random = js_sys::Math::random();
    (random * 22.0).floor() as i32 + 1
}

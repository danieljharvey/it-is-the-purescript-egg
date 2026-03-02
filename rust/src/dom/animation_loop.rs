use std::cell::RefCell;
use std::rc::Rc;
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;

use crate::dom::canvas::CanvasData;
use crate::dom::renderer::render_game_state;
use crate::logic::take_turn;
use crate::types::game_state::GameState;

use super::events::InputEventRef;

pub fn start_animation_loop(
    canvas_data: Rc<RefCell<CanvasData>>,
    game_state: Rc<RefCell<GameState>>,
    input_ref: InputEventRef,
    on_complete: Rc<dyn Fn()>,
) {
    let f: Rc<RefCell<Option<Closure<dyn FnMut()>>>> = Rc::new(RefCell::new(None));
    let g = f.clone();

    let last_time: Rc<RefCell<f64>> = Rc::new(RefCell::new(performance_now()));

    // Clone Rc's for the closure
    let canvas_data_loop = canvas_data.clone();
    let game_state_loop = game_state.clone();
    let input_ref_loop = input_ref.clone();

    let closure = Closure::wrap(Box::new(move || {
        let now = performance_now();
        let old_time = *last_time.borrow();
        *last_time.borrow_mut() = now;
        let delta = (now - old_time) as i32;

        let input = input_ref_loop.borrow().clone();
        let old_state = game_state_loop.borrow().clone();

        let new_state = take_turn::go(delta, input.as_ref(), &old_state);

        match new_state {
            Some(new_gs) => {
                // Render
                {
                    let mut cd = canvas_data_loop.borrow_mut();
                    let _ = render_game_state(&mut cd, &old_state, &new_gs);
                }

                // Update state
                *game_state_loop.borrow_mut() = new_gs;

                // Clear input
                *input_ref_loop.borrow_mut() = None;

                // Request next frame
                request_animation_frame(f.borrow().as_ref().unwrap());
            }
            None => {
                // Level complete
                on_complete();
            }
        }
    }) as Box<dyn FnMut()>);

    // Initial callback with time 0
    {
        let input = input_ref.borrow().clone();
        let old_state = game_state.borrow().clone();
        if let Some(new_gs) = take_turn::go(0, input.as_ref(), &old_state) {
            let mut cd = canvas_data.borrow_mut();
            let _ = render_game_state(&mut cd, &old_state, &new_gs);
            *game_state.borrow_mut() = new_gs;
        }
        *input_ref.borrow_mut() = None;
    }

    *g.borrow_mut() = Some(closure);
    request_animation_frame(g.borrow().as_ref().unwrap());
}

fn performance_now() -> f64 {
    web_sys::window()
        .and_then(|w| w.performance())
        .map(|p| p.now())
        .unwrap_or(0.0)
}

fn request_animation_frame(f: &Closure<dyn FnMut()>) {
    web_sys::window()
        .unwrap()
        .request_animation_frame(f.as_ref().unchecked_ref())
        .unwrap();
}

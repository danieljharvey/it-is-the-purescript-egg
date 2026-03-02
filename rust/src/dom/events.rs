use std::cell::RefCell;
use std::rc::Rc;
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;
use web_sys::KeyboardEvent;

use crate::types::input_event::InputEvent;

pub type InputEventRef = Rc<RefCell<Option<InputEvent>>>;

pub fn setup_events(input_ref: &InputEventRef) -> Result<(), JsValue> {
    setup_keyboard_listener(input_ref)?;
    setup_resize_listener(input_ref)?;
    setup_touch_listener(input_ref)?;

    // Fire initial resize event
    fire_resize_event(input_ref)?;
    Ok(())
}

fn fire_resize_event(input_ref: &InputEventRef) -> Result<(), JsValue> {
    let window = web_sys::window().ok_or("no window")?;
    let width = window.inner_width()?.as_f64().unwrap_or(480.0) as i32;
    let height = window.inner_height()?.as_f64().unwrap_or(480.0) as i32;
    *input_ref.borrow_mut() = Some(InputEvent::ResizeWindow(width, height));
    Ok(())
}

fn setup_keyboard_listener(input_ref: &InputEventRef) -> Result<(), JsValue> {
    let window = web_sys::window().ok_or("no window")?;
    let input_ref = input_ref.clone();
    let closure = Closure::wrap(Box::new(move |e: KeyboardEvent| {
        let event = match e.code().as_str() {
            "ArrowLeft" => Some(InputEvent::LeftArrow),
            "ArrowRight" => Some(InputEvent::RightArrow),
            "Space" => Some(InputEvent::Pause),
            code => Some(InputEvent::KeyPress(code.to_string())),
        };
        if let Some(evt) = event {
            *input_ref.borrow_mut() = Some(evt);
        }
    }) as Box<dyn FnMut(_)>);

    window.add_event_listener_with_callback("keydown", closure.as_ref().unchecked_ref())?;
    closure.forget();
    Ok(())
}

fn setup_resize_listener(input_ref: &InputEventRef) -> Result<(), JsValue> {
    let window = web_sys::window().ok_or("no window")?;
    let input_ref = input_ref.clone();
    let closure = Closure::wrap(Box::new(move |_: web_sys::Event| {
        if let Some(w) = web_sys::window() {
            let width = w.inner_width().unwrap_or(JsValue::from(480)).as_f64().unwrap_or(480.0) as i32;
            let height = w.inner_height().unwrap_or(JsValue::from(480)).as_f64().unwrap_or(480.0) as i32;
            *input_ref.borrow_mut() = Some(InputEvent::ResizeWindow(width, height));
        }
    }) as Box<dyn FnMut(_)>);

    window.add_event_listener_with_callback("resize", closure.as_ref().unchecked_ref())?;
    closure.forget();
    Ok(())
}

fn setup_touch_listener(input_ref: &InputEventRef) -> Result<(), JsValue> {
    let document = web_sys::window()
        .ok_or("no window")?
        .document()
        .ok_or("no document")?;
    let wrapper = match document.get_element_by_id("wrapper") {
        Some(el) => el,
        None => return Ok(()), // no wrapper element, skip touch
    };

    // Track touch start position
    let touch_start_x: Rc<RefCell<f64>> = Rc::new(RefCell::new(0.0));
    let touch_start_y: Rc<RefCell<f64>> = Rc::new(RefCell::new(0.0));

    // touchstart
    {
        let start_x = touch_start_x.clone();
        let start_y = touch_start_y.clone();
        let closure = Closure::wrap(Box::new(move |e: web_sys::TouchEvent| {
            if let Some(touch) = e.touches().get(0) {
                *start_x.borrow_mut() = touch.client_x() as f64;
                *start_y.borrow_mut() = touch.client_y() as f64;
            }
        }) as Box<dyn FnMut(_)>);
        wrapper.add_event_listener_with_callback("touchstart", closure.as_ref().unchecked_ref())?;
        closure.forget();
    }

    // touchend - detect swipe
    {
        let start_x = touch_start_x;
        let start_y = touch_start_y;
        let input_ref = input_ref.clone();
        let swipe_threshold = 50.0;

        let closure = Closure::wrap(Box::new(move |e: web_sys::TouchEvent| {
            if let Some(touch) = e.changed_touches().get(0) {
                let dx = touch.client_x() as f64 - *start_x.borrow();
                let dy = touch.client_y() as f64 - *start_y.borrow();

                if dx.abs() > dy.abs() && dx.abs() > swipe_threshold {
                    let event = if dx < 0.0 {
                        InputEvent::LeftArrow
                    } else {
                        InputEvent::RightArrow
                    };
                    *input_ref.borrow_mut() = Some(event);
                }
            }
        }) as Box<dyn FnMut(_)>);
        wrapper.add_event_listener_with_callback("touchend", closure.as_ref().unchecked_ref())?;
        closure.forget();
    }

    Ok(())
}

use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;
use wasm_bindgen_futures::JsFuture;
use web_sys::{HtmlImageElement, Request, RequestInit, Response};

use crate::logic::load_level::read_level;
use crate::types::level::Level;
use crate::types::resource_url::ResourceUrl;

pub async fn fetch_text(url: &str) -> Result<String, JsValue> {
    let opts = RequestInit::new();
    opts.set_method("GET");

    let request = Request::new_with_str_and_init(url, &opts)?;
    let window = web_sys::window().ok_or("no window")?;
    let resp_value = JsFuture::from(window.fetch_with_request(&request)).await?;
    let resp: Response = resp_value.dyn_into()?;
    let text = JsFuture::from(resp.text()?).await?;
    text.as_string()
        .ok_or_else(|| JsValue::from_str("not a string"))
}

pub async fn load_level(id: i32) -> Option<Level> {
    let url = format!("/levels/{}.json", id);
    let text = fetch_text(&url).await.ok()?;
    read_level(&text)
}

pub async fn load_level_from_url(url: &str) -> Option<Level> {
    let text = fetch_text(url).await.ok()?;
    read_level(&text)
}

/// Load image using JS Promise - waits for onload event
pub async fn load_image_via_promise(url: &str) -> Result<HtmlImageElement, JsValue> {
    let document = web_sys::window()
        .ok_or("no window")?
        .document()
        .ok_or("no document")?;
    let img = document
        .create_element("img")?
        .dyn_into::<HtmlImageElement>()?;

    let img_clone = img.clone();
    let promise = js_sys::Promise::new(&mut move |resolve, reject| {
        let resolve_cb = Closure::once(move || {
            resolve.call0(&JsValue::NULL).unwrap();
        });
        let reject_cb = Closure::once(move || {
            reject
                .call1(&JsValue::NULL, &JsValue::from_str("load error"))
                .unwrap();
        });
        img_clone.set_onload(Some(resolve_cb.as_ref().unchecked_ref()));
        img_clone.set_onerror(Some(reject_cb.as_ref().unchecked_ref()));
        resolve_cb.forget();
        reject_cb.forget();
    });

    img.set_src(url);
    JsFuture::from(promise).await?;
    Ok(img)
}

pub async fn load_all_images(
    resources: &[ResourceUrl],
) -> Result<super::canvas::ImageSourceMap, JsValue> {
    let mut map = super::canvas::ImageSourceMap::new();
    for resource in resources {
        let url = resource.to_string();
        match load_image_via_promise(&url).await {
            Ok(img) => {
                map.insert(resource.clone(), img);
            }
            Err(e) => {
                web_sys::console::warn_1(&JsValue::from_str(&format!(
                    "Failed to load image {}: {:?}",
                    url, e
                )));
            }
        }
    }
    Ok(map)
}

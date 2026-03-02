#[derive(Clone, Debug, PartialEq, Eq)]
pub enum InputEvent {
    ResizeWindow(i32, i32),
    KeyPress(String),
    LeftArrow,
    RightArrow,
    Pause,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Clockwise {
    Clockwise,
    AntiClockwise,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Action {
    Paused,
    Playing,
    Turning(Clockwise, i32),
    Resize(i32, i32, Box<Action>),
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ScreenSize {
    width: i32,
    height: i32,
}

impl ScreenSize {
    pub fn new(width: i32, height: i32) -> Self {
        ScreenSize {
            width: width.max(1),
            height: height.max(1),
        }
    }

    pub fn width(&self) -> i32 {
        self.width
    }

    pub fn height(&self) -> i32 {
        self.height
    }

    pub fn smallest(&self) -> i32 {
        self.width.min(self.height)
    }
}

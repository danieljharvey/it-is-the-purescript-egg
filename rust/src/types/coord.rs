use std::ops::Add;

pub const SUBPARTS: i32 = 64;

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct Coord {
    pub x: i32,
    pub y: i32,
    pub offset_x: i32,
    pub offset_y: i32,
}

impl Coord {
    pub fn new(x: i32, y: i32) -> Self {
        Coord {
            x,
            y,
            offset_x: 0,
            offset_y: 0,
        }
    }

    pub fn new_full(x: i32, y: i32, offset_x: i32, offset_y: i32) -> Self {
        Coord {
            x,
            y,
            offset_x,
            offset_y,
        }
    }

    pub fn create_move_coord(speed: i32, dir: &Coord) -> Self {
        Coord {
            x: 0,
            y: 0,
            offset_x: speed * dir.x,
            offset_y: speed * dir.y,
        }
    }

    pub fn total_x(&self) -> i32 {
        self.x * SUBPARTS + self.offset_x
    }

    pub fn total_y(&self) -> i32 {
        self.y * SUBPARTS + self.offset_y
    }

    pub fn invert(&self) -> Self {
        Coord {
            x: -self.x,
            y: -self.y,
            offset_x: -self.offset_x,
            offset_y: -self.offset_y,
        }
    }

    pub fn difference(&self, other: &Coord) -> Self {
        self.clone() + other.invert()
    }

    pub fn is_centered(&self) -> bool {
        self.offset_x == 0 && self.offset_y == 0
    }

    pub fn center(&self) -> Self {
        Coord {
            x: self.x,
            y: self.y,
            offset_x: 0,
            offset_y: 0,
        }
    }

    pub fn eq_ints(&self, x: i32, y: i32) -> bool {
        self.x == x && self.y == y
    }

    pub fn is_stationary(&self) -> bool {
        self.x == 0 && self.y == 0 && self.offset_x == 0 && self.offset_y == 0
    }
}

impl Add for Coord {
    type Output = Coord;

    fn add(self, other: Coord) -> Coord {
        Coord {
            x: self.x + other.x,
            y: self.y + other.y,
            offset_x: self.offset_x + other.offset_x,
            offset_y: self.offset_y + other.offset_y,
        }
    }
}

impl<'a, 'b> Add<&'b Coord> for &'a Coord {
    type Output = Coord;

    fn add(self, other: &'b Coord) -> Coord {
        Coord {
            x: self.x + other.x,
            y: self.y + other.y,
            offset_x: self.offset_x + other.offset_x,
            offset_y: self.offset_y + other.offset_y,
        }
    }
}

impl std::fmt::Display for Coord {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "({}.{}, {}.{})",
            self.x, self.offset_x, self.y, self.offset_y
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_coord_add() {
        let a = Coord::new(1, 2);
        let b = Coord::new(3, 4);
        let c = a + b;
        assert_eq!(c, Coord::new(4, 6));
    }

    #[test]
    fn test_total() {
        let c = Coord::new_full(2, 3, 10, 20);
        assert_eq!(c.total_x(), 2 * 64 + 10);
        assert_eq!(c.total_y(), 3 * 64 + 20);
    }

    #[test]
    fn test_invert() {
        let c = Coord::new_full(1, -2, 3, -4);
        let inv = c.invert();
        assert_eq!(inv, Coord::new_full(-1, 2, -3, 4));
    }

    #[test]
    fn test_is_centered() {
        assert!(Coord::new(5, 3).is_centered());
        assert!(!Coord::new_full(5, 3, 1, 0).is_centered());
    }

    #[test]
    fn test_is_stationary() {
        assert!(Coord::new(0, 0).is_stationary());
        assert!(!Coord::new(1, 0).is_stationary());
        assert!(!Coord::new_full(0, 0, 1, 0).is_stationary());
    }

    #[test]
    fn test_create_move_coord() {
        let dir = Coord::new(1, 0);
        let mc = Coord::create_move_coord(5, &dir);
        assert_eq!(mc, Coord::new_full(0, 0, 5, 0));
    }
}
